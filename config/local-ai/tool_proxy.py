#!/usr/bin/env python3
"""Tiny OpenAI-compatible proxy that normalizes local model tool calls.

The local Qwen model often answers a tool request with raw JSON such as
{"name": "list_agenda", "arguments": {"days": 7}}. llama.cpp does not always
convert that into a native `tool_calls` response. This proxy sits in front of
llama-server and rewrites those replies into the format clients expect.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import time
import uuid
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.error import HTTPError
from urllib.request import Request, urlopen

TOOL_TAGS = re.compile(r"</?tool_call>|</?functionCall>|```(?:json)?|```", re.I)


def extract_tool_call(content: str):
    """Return (name, arguments dict) if content looks like a tool call."""
    if not content or not isinstance(content, str):
        return None
    text = content.strip()
    text = re.sub(r"^<functionCall>\s*|\s*</functionCall>$", "", text, flags=re.I).strip()
    text = re.sub(r"^<tool_call>\s*|\s*</tool_call>$", "", text, flags=re.I).strip()
    text = re.sub(r"^```(?:json)?\s*|\s*```$", "", text, flags=re.I).strip()
    if not text.startswith("{"):
        return None
    try:
        data = json.loads(text)
    except Exception:
        return None
    if isinstance(data, list) and data:
        data = data[0]
    if not isinstance(data, dict):
        return None
    name = data.get("name") or (data.get("function") or {}).get("name")
    args = data.get("arguments", data.get("args", {}))
    if isinstance(args, str):
        try:
            args = json.loads(args)
        except Exception:
            args = {}
    if not name or not isinstance(args, dict):
        return None
    return str(name), args


def transform(payload: dict, has_tools: bool) -> dict:
    if not has_tools or not isinstance(payload, dict):
        return payload
    choices = payload.get("choices") or []
    if not choices:
        return payload
    for choice in choices:
        message = choice.get("message") or {}
        content = message.get("content") or ""
        found = extract_tool_call(content)
        if not found:
            continue
        name, args = found
        message["content"] = None
        message["tool_calls"] = [
            {
                "id": f"call_{uuid.uuid4().hex[:12]}",
                "type": "function",
                "function": {
                    "name": name,
                    "arguments": json.dumps(args, separators=(",", ":")),
                },
            }
        ]
        choice["message"] = message
        choice["finish_reason"] = "tool_calls"
    return payload


def sse_chunks(payload: dict):
    """Turn a non-stream completion into a small SSE stream."""
    choice = (payload.get("choices") or [{}])[0]
    message = choice.get("message") or {}
    base = {
        "id": payload.get("id", f"chatcmpl-{uuid.uuid4().hex[:12]}"),
        "object": "chat.completion.chunk",
        "created": payload.get("created", int(time.time())),
        "model": payload.get("model", "local"),
    }

    def chunk(delta, finish_reason=None):
        item = dict(base)
        item["choices"] = [
            {"index": 0, "delta": delta, "finish_reason": finish_reason}
        ]
        return f"data: {json.dumps(item, separators=(',', ':'))}\n\n".encode()

    content = message.get("content")
    if content:
        yield chunk({"role": "assistant", "content": content})
    for tc in message.get("tool_calls") or []:
        fn = tc.get("function") or {}
        yield chunk(
            {
                "role": "assistant",
                "tool_calls": [
                    {
                        "index": 0,
                        "id": tc.get("id"),
                        "type": "function",
                        "function": {
                            "name": fn.get("name", ""),
                            "arguments": fn.get("arguments", "{}"),
                        },
                    }
                ],
            }
        )
    yield chunk({}, choice.get("finish_reason") or "stop")
    yield b"data: [DONE]\n\n"


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    server_version = "TARDISToolProxy/1.0"

    def log_message(self, fmt: str, *args) -> None:
        print(f"proxy: {fmt % args}", file=sys.stderr)

    def _forward(self, method: str) -> None:
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length) if length else None
        path = self.path
        is_chat = path.endswith("/chat/completions") or path == "/v1/chat/completions"
        stream = False
        has_tools = False
        if is_chat and body:
            try:
                request_payload = json.loads(body)
                stream = bool(request_payload.get("stream"))
                has_tools = bool(request_payload.get("tools"))
                print(f"proxy: {path} keys={sorted(request_payload.keys())} tools={has_tools}", file=sys.stderr)
                if stream:
                    request_payload["stream"] = False
                    body = json.dumps(request_payload).encode()
            except Exception as exc:
                print(f"proxy: request parse failed: {exc}", file=sys.stderr)
        headers = {}
        for key, value in self.headers.items():
            if key.lower() not in ("host", "content-length", "connection", "accept-encoding"):
                headers[key] = value
        req = Request(
            f"{self.server.backend}{path}",
            data=body,
            headers=headers,
            method=method,
        )
        try:
            with urlopen(req, timeout=300) as response:
                status = response.status
                resp_headers = dict(response.headers.items())
                raw = response.read()
        except HTTPError as exc:
            status = exc.code
            resp_headers = dict(exc.headers.items()) if exc.headers else {}
            raw = exc.read()
        except Exception as exc:
            payload = json.dumps({"error": {"message": str(exc)}}).encode()
            self.send_response(502)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(payload)))
            self.end_headers()
            self.wfile.write(payload)
            return

        if is_chat and raw:
            try:
                result = json.loads(raw)
                result = transform(result, has_tools)
                if stream:
                    raw = b"".join(sse_chunks(result))
                    resp_headers["Content-Type"] = "text/event-stream"
                else:
                    raw = json.dumps(result).encode()
            except Exception as exc:
                print(f"proxy: transform failed: {exc}", file=sys.stderr)

        self.send_response(status)
        skip = {
            "content-length",
            "transfer-encoding",
            "connection",
            "content-encoding",
            "accept-encoding",
        }
        for key, value in resp_headers.items():
            if key.lower() not in skip:
                self.send_header(key, value)
        self.send_header("Content-Length", str(len(raw)))
        self.end_headers()
        self.wfile.write(raw)

    def do_GET(self):
        self._forward("GET")

    def do_POST(self):
        self._forward("POST")

    def do_PUT(self):
        self._forward("PUT")

    def do_DELETE(self):
        self._forward("DELETE")

    def do_PATCH(self):
        self._forward("PATCH")


def main() -> int:
    parser = argparse.ArgumentParser(description="Local AI tool-call compatibility proxy")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8080)
    parser.add_argument("--backend", default="http://127.0.0.1:8081")
    args = parser.parse_args()
    server = ThreadingHTTPServer((args.host, args.port), Handler)
    server.backend = args.backend.rstrip("/")
    print(f"TARDIS tool proxy on http://{args.host}:{args.port} -> {server.backend}", file=sys.stderr)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
