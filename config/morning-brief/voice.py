#!/usr/bin/env python3
"""Local TTS with a calm, slightly eccentric TARDIS character."""
from __future__ import annotations

import argparse
import json
import os
import random
import re
import subprocess
import sys
from pathlib import Path

BASE = Path.home() / "AI" / "morning-brief"
CONFIG_PATH = BASE / "config.json"
STATE_DIR = Path.home() / ".local" / "state" / "tardis-voice"
STATE_DIR.mkdir(parents=True, exist_ok=True)

DEFAULTS = {
    "enabled": True,
    "piper": "~/.local/share/tardis-voice/venv/bin/piper",
    "model": "~/.local/share/tardis-voice/models/en_GB-alan-medium.onnx",
    "config": "~/.local/share/tardis-voice/models/en_GB-alan-medium.onnx.json",
    "player": "paplay",
    "length_scale": 1.05,
    "noise_scale": 0.667,
    "noise_w": 0.8,
    "sentence_silence": 0.35,
    "greetings": [],
    "signoffs": [],
}


def load_voice_config() -> dict:
    cfg = json.loads(json.dumps(DEFAULTS))
    if CONFIG_PATH.exists():
        try:
            user_cfg = json.loads(CONFIG_PATH.read_text())
            cfg.update(user_cfg.get("voice", {}))
        except Exception:
            pass
    return cfg


def clean_text(text: str) -> str:
    text = re.sub(r"```.*?```", " ", text, flags=re.S)
    text = re.sub(r"`([^`]*)`", r"\1", text)
    text = re.sub(r"[*_#>]", "", text)
    text = re.sub(r"^\s*[-•]\s*", "", text, flags=re.M)
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def with_persona(text: str, cfg: dict) -> str:
    parts = []
    greetings = cfg.get("greetings") or []
    signoffs = cfg.get("signoffs") or []
    if greetings:
        parts.append(random.choice(greetings))
    parts.append(text)
    if signoffs:
        parts.append(random.choice(signoffs))
    return " ".join(part for part in parts if part)


def synthesize(text: str, output: Path | None = None) -> tuple[Path, str]:
    cfg = load_voice_config()
    spoken = with_persona(clean_text(text), cfg)
    piper = Path(str(cfg["piper"])).expanduser()
    model = Path(str(cfg["model"])).expanduser()
    config = Path(str(cfg["config"])).expanduser() if cfg.get("config") else None

    if not piper.exists():
        raise RuntimeError(f"Piper not found: {piper}")
    if not model.exists():
        raise RuntimeError(f"Voice model not found: {model}")

    out = Path(output) if output else STATE_DIR / "latest.wav"
    out.parent.mkdir(parents=True, exist_ok=True)

    command = [
        str(piper),
        "--model", str(model),
        "--output-file", str(out),
        "--length-scale", str(cfg.get("length_scale", 1.05)),
        "--noise-scale", str(cfg.get("noise_scale", 0.667)),
        "--noise-w-scale", str(cfg.get("noise_w", 0.8)),
        "--sentence-silence", str(cfg.get("sentence_silence", 0.35)),
    ]
    if config and config.exists():
        command += ["--config", str(config)]

    subprocess.run(command, input=spoken.encode("utf-8"), check=True)
    return out, spoken


def play(path: Path) -> None:
    cfg = load_voice_config()
    player = cfg.get("player", "paplay")
    env = os.environ.copy()
    env.setdefault("PULSE_SERVER", f"unix:/run/user/{os.getuid()}/pulse/native")
    subprocess.run([player, str(path)], env=env, check=False)


def speak(text: str, play_audio: bool = True, output: Path | None = None) -> dict:
    wav, spoken = synthesize(text, output)
    if play_audio:
        play(wav)
    return {"wav": str(wav), "spoken": spoken}


def main() -> int:
    parser = argparse.ArgumentParser(description="TARDIS local voice")
    parser.add_argument("text", nargs="*", help="Text to speak")
    parser.add_argument("--file", help="Read text from a file")
    parser.add_argument("--output", help="Save WAV here instead of the default")
    parser.add_argument("--no-play", action="store_true", help="Synthesize only")
    args = parser.parse_args()

    if args.file:
        text = Path(args.file).read_text()
    elif args.text:
        text = " ".join(args.text)
    elif not sys.stdin.isatty():
        text = sys.stdin.read()
    else:
        parser.print_help()
        return 1

    try:
        result = speak(text, play_audio=not args.no_play, output=Path(args.output) if args.output else None)
    except Exception as exc:
        print(f"voice error: {exc}", file=sys.stderr)
        return 1

    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
