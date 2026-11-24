#!/usr/bin/env python3
"""TARDIS Morning Brief skill and shared agenda store."""
from __future__ import annotations

import argparse
import html
import json
import os
import re
import subprocess
import sys
import time
import uuid
from datetime import datetime, timedelta
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import Request, urlopen

import feedparser

import voice

BASE = Path.home() / "AI" / "morning-brief"
CONFIG_PATH = BASE / "config.json"
STORE_PATH = BASE / "reminders.json"
LATEST_PATH = BASE / "latest.txt"

DEFAULT_CONFIG = {
    "location": {
        "name": "Harrow, Ontario",
        "lat": 42.03339,
        "lon": -82.91654,
        "timezone": "America/Toronto",
    },
    "news": {
        "feeds": [
            {"name": "CBC Ontario", "url": "https://www.cbc.ca/webfeed/rss/rss-ontario"},
            {"name": "BBC World", "url": "https://feeds.bbci.co.uk/news/world/rss.xml"},
            {
                "name": "Harrow News",
                "url": "https://news.google.com/rss/search?q=Harrow%20Ontario&hl=en-CA&gl=CA&ceid=CA:en",
            },
        ],
        "per_feed": 3,
        "max_headlines": 9,
    },
    "llm": {
        "url": "http://127.0.0.1:8080/v1/chat/completions",
        "model": "qwen2.5-coder-7b",
        "max_tokens": 700,
        "temperature": 0.3,
    },
    "notify": True,
    "brief_days": 7,
}

WMO = {
    0: "Clear sky", 1: "Mainly clear", 2: "Partly cloudy", 3: "Overcast",
    45: "Fog", 48: "Rime fog", 51: "Light drizzle", 53: "Drizzle",
    55: "Heavy drizzle", 56: "Freezing drizzle", 57: "Freezing drizzle",
    61: "Light rain", 63: "Rain", 65: "Heavy rain", 66: "Freezing rain",
    67: "Freezing rain", 71: "Light snow", 73: "Snow", 75: "Heavy snow",
    77: "Snow grains", 80: "Rain showers", 81: "Rain showers",
    82: "Violent showers", 85: "Snow showers", 86: "Snow showers",
    95: "Thunderstorm", 96: "Thunderstorm with hail", 99: "Thunderstorm with hail",
}


# --------------------------------------------------------------------------
# config / store
# --------------------------------------------------------------------------

def load_config() -> dict:
    cfg = json.loads(json.dumps(DEFAULT_CONFIG))
    if CONFIG_PATH.exists():
        try:
            user_cfg = json.loads(CONFIG_PATH.read_text())
            for key, value in user_cfg.items():
                if isinstance(value, dict) and isinstance(cfg.get(key), dict):
                    cfg[key].update(value)
                else:
                    cfg[key] = value
        except Exception as exc:
            print(f"warning: bad config, using defaults: {exc}", file=sys.stderr)
    return cfg


def load_store() -> dict:
    if not STORE_PATH.exists():
        return {"items": []}
    try:
        data = json.loads(STORE_PATH.read_text())
        if not isinstance(data.get("items"), list):
            data["items"] = []
        return data
    except Exception:
        return {"items": []}


def save_store(store: dict) -> None:
    BASE.mkdir(parents=True, exist_ok=True)
    STORE_PATH.write_text(json.dumps(store, indent=2) + "\n")


# --------------------------------------------------------------------------
# date helpers
# --------------------------------------------------------------------------

def parse_iso(value: str | None) -> datetime | None:
    if not value:
        return None
    try:
        return datetime.fromisoformat(str(value))
    except Exception:
        return None


def parse_clock(text: str, base: datetime) -> datetime:
    text = text.strip().lower().replace(" ", "")
    pm = text.endswith("pm")
    am = text.endswith("am")
    if pm or am:
        text = text[:-2]
    if ":" in text:
        hour_str, minute_str = text.split(":", 1)
        hour, minute = int(hour_str), int(minute_str)
    else:
        hour, minute = int(text), 0
    if hour == 12:
        hour = 0
    if pm:
        hour += 12
    return base.replace(hour=hour, minute=minute, second=0, microsecond=0)


def parse_due(value: str | None, now: datetime | None = None) -> datetime | None:
    if not value or not str(value).strip():
        return None
    now = now or datetime.now()
    raw = str(value).strip()
    low = raw.lower()
    if low.startswith("today "):
        return parse_clock(raw[6:], now)
    if low.startswith("tomorrow "):
        return parse_clock(raw[9:], now + timedelta(days=1))
    if low.startswith("in "):
        parts = low[3:].split()
        if len(parts) == 2:
            count = int(parts[0])
            unit = parts[1]
            if unit.startswith("m"):
                return now + timedelta(minutes=count)
            if unit.startswith("h"):
                return now + timedelta(hours=count)
            if unit.startswith("d"):
                return now + timedelta(days=count)
        raise ValueError(f"Cannot parse relative time: {raw}")
    parsed = parse_iso(raw)
    if parsed is None:
        raise ValueError(f"Cannot parse date/time: {raw}")
    return parsed


def fmt_due(value: str | None) -> str:
    dt = parse_iso(value)
    if dt is None:
        return "No date"
    return dt.strftime("%a %b %d  %I:%M %p").replace(" 0", "  ")


# --------------------------------------------------------------------------
# weather / news
# --------------------------------------------------------------------------

def fetch_weather(cfg: dict) -> dict:
    loc = cfg["location"]
    params = {
        "latitude": loc["lat"],
        "longitude": loc["lon"],
        "current": "temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m",
        "daily": "weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max",
        "timezone": loc["timezone"],
        "forecast_days": 1,
        "temperature_unit": "celsius",
        "wind_speed_unit": "kmh",
    }
    url = "https://api.open-meteo.com/v1/forecast?" + urlencode(params)
    try:
        with urlopen(Request(url, headers={"User-Agent": "TARDIS-Brief/1.0"}), timeout=20) as response:
            data = json.load(response)
    except Exception as exc:
        return {"location": loc["name"], "error": str(exc)}

    cur = data.get("current", {})
    daily = data.get("daily", {})

    def first(key: str):
        values = daily.get(key) or []
        return values[0] if values else None

    return {
        "location": loc["name"],
        "time": cur.get("time"),
        "temperature_c": cur.get("temperature_2m"),
        "feels_like_c": cur.get("apparent_temperature"),
        "condition": WMO.get(cur.get("weather_code"), "Unknown conditions"),
        "humidity": cur.get("relative_humidity_2m"),
        "wind_kmh": cur.get("wind_speed_10m"),
        "high_c": first("temperature_2m_max"),
        "low_c": first("temperature_2m_min"),
        "precip_prob": first("precipitation_probability_max"),
    }


def clean_title(value: str) -> str:
    return html.unescape(re.sub(r"<[^>]+>", "", value or "")).strip()


def fetch_news(cfg: dict) -> list[dict]:
    per_feed = int(cfg["news"].get("per_feed", 3))
    max_items = int(cfg["news"].get("max_headlines", 9))
    items: list[dict] = []
    seen: set[str] = set()
    for feed in cfg["news"].get("feeds", []):
        try:
            request = Request(feed["url"], headers={"User-Agent": "TARDIS-Brief/1.0"})
            with urlopen(request, timeout=15) as response:
                raw = response.read()
            parsed = feedparser.parse(raw)
        except Exception:
            continue
        for entry in getattr(parsed, "entries", [])[:per_feed]:
            title = clean_title(entry.get("title", ""))
            if not title or title.lower() in seen:
                continue
            seen.add(title.lower())
            stamp = 0.0
            if entry.get("published_parsed"):
                try:
                    stamp = time.mktime(entry.published_parsed)
                except Exception:
                    pass
            items.append({
                "source": feed.get("name", "News"),
                "title": title,
                "link": entry.get("link", ""),
                "published": entry.get("published", ""),
                "_ts": stamp,
            })
    items.sort(key=lambda item: item["_ts"], reverse=True)
    for item in items:
        item.pop("_ts", None)
    return items[:max_items]


# --------------------------------------------------------------------------
# agenda operations
# --------------------------------------------------------------------------

def find_item(store: dict, needle: str) -> dict | None:
    needle = needle.lower()
    for item in store["items"]:
        if item["id"].lower() == needle or item["id"].lower().startswith(needle):
            return item
    return None


def add_item(text: str, kind: str, due: str | None, tags: list[str]) -> dict:
    if not text.strip():
        raise ValueError("Text cannot be empty")
    if kind not in ("appointment", "reminder"):
        raise ValueError("Kind must be appointment or reminder")
    store = load_store()
    item = {
        "id": uuid.uuid4().hex[:8],
        "kind": kind,
        "text": text.strip(),
        "due": parse_due(due).isoformat(timespec="seconds") if parse_due(due) else None,
        "created": datetime.now().isoformat(timespec="seconds"),
        "done": False,
        "tags": [tag.strip() for tag in tags if tag.strip()],
    }
    store["items"].append(item)
    save_store(store)
    return item


def list_items(days: int = 7, include_done: bool = False, kind: str | None = None) -> list[dict]:
    now = datetime.now()
    end = now + timedelta(days=days)
    result = []
    for item in load_store()["items"]:
        if item.get("done") and not include_done:
            continue
        if kind and item.get("kind") != kind:
            continue
        due = parse_iso(item.get("due"))
        if due is None or due <= end:
            result.append(item)
    result.sort(key=lambda item: (item.get("due") or "9999", item.get("text", "")))
    return result


def item_public(item: dict) -> dict:
    due = parse_iso(item.get("due"))
    return {
        "id": item["id"],
        "kind": item.get("kind", "reminder"),
        "text": item.get("text", ""),
        "due": item.get("due"),
        "due_label": fmt_due(item.get("due")),
        "overdue": bool(due and due < datetime.now()),
        "done": bool(item.get("done")),
        "tags": item.get("tags", []),
    }


def collect(cfg: dict, days: int | None = None) -> dict:
    window = days if days is not None else int(cfg.get("brief_days", 7))
    agenda = [item_public(item) for item in list_items(days=window)]
    return {
        "generated_at": datetime.now().isoformat(timespec="seconds"),
        "location": cfg["location"]["name"],
        "weather": fetch_weather(cfg),
        "news": fetch_news(cfg),
        "agenda": agenda,
    }


# --------------------------------------------------------------------------
# briefing generation / delivery
# --------------------------------------------------------------------------

def format_raw_brief(data: dict) -> str:
    weather = data.get("weather", {})
    lines = [f"TARDIS MORNING BRIEF // {data['generated_at'][:10]}", ""]
    lines.append("WEATHER")
    if weather.get("error"):
        lines.append(f"  Weather unavailable: {weather['error']}")
    else:
        lines.append(
            f"  {weather.get('condition')}, {weather.get('temperature_c')}C "
            f"(feels {weather.get('feels_like_c')}C). "
            f"High {weather.get('high_c')}C / low {weather.get('low_c')}C, "
            f"precip {weather.get('precip_prob')}%, wind {weather.get('wind_kmh')} km/h."
        )
    lines += ["", "HEADLINES"]
    if data.get("news"):
        for item in data["news"]:
            lines.append(f"  - {item['title']} ({item['source']})")
    else:
        lines.append("  No headlines available.")
    lines += ["", "AGENDA / REMINDERS"]
    if data.get("agenda"):
        for item in data["agenda"]:
            mark = "APPT" if item["kind"] == "appointment" else "NOTE"
            flag = " [OVERDUE]" if item["overdue"] else ""
            lines.append(f"  - [{mark}] {item['due_label']} — {item['text']}{flag}")
    else:
        lines.append("  Nothing scheduled.")
    return "\n".join(lines)


SYSTEM_PROMPT = """You are TARDIS, the ship's computer, delivering a morning brief on a local machine.
You are calm, capable, dryly humorous, and faintly eccentric — like a good companion
who has seen a great many timelines. Speak to the user as "Doctor".

Turn the supplied JSON data into a concise, useful morning brief.

Rules:
- Do not add a greeting or sign-off; the local voice layer supplies those.
- Use exactly these sections in this order: WEATHER, HEADLINES, AGENDA, REMINDERS.
- Use short bullet points. Keep the whole brief under 250 words.
- Use only facts present in the data. Never invent news, weather, or appointments.
- If a section is empty, write "Nothing scheduled" or "No headlines available".
- Mark overdue items clearly.
- This text may be read aloud locally, so avoid markdown symbols and emoji.
"""


def call_llm(data: dict, cfg: dict) -> str:
    payload = {
        "model": cfg["llm"]["model"],
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {
                "role": "user",
                "content": "Here is this morning's data as JSON:\n\n"
                + json.dumps(data, indent=2)
                + "\n\nWrite the brief now.",
            },
        ],
        "temperature": float(cfg["llm"].get("temperature", 0.3)),
        "max_tokens": int(cfg["llm"].get("max_tokens", 700)),
    }
    try:
        request = Request(
            cfg["llm"]["url"],
            data=json.dumps(payload).encode(),
            headers={"Content-Type": "application/json"},
        )
        with urlopen(request, timeout=180) as response:
            result = json.load(response)
        return result["choices"][0]["message"]["content"].strip()
    except Exception as exc:
        print(f"warning: LLM unavailable ({exc}); using plain brief", file=sys.stderr)
        return format_raw_brief(data)


def send_notification(brief: str) -> None:
    body = " ".join(brief.split())[:500]
    env = os.environ.copy()
    env.setdefault("DBUS_SESSION_BUS_ADDRESS", f"unix:path=/run/user/{os.getuid()}/bus")
    try:
        subprocess.run(
            [
                "notify-send", "-a", "TARDIS Brief", "-t", "20000",
                "TARDIS Morning Brief", body,
            ],
            env=env,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        )
    except Exception as exc:
        print(f"warning: notification failed: {exc}", file=sys.stderr)


# --------------------------------------------------------------------------
# CLI
# --------------------------------------------------------------------------

def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="TARDIS Morning Brief and agenda")
    sub = parser.add_subparsers(dest="command")

    run = sub.add_parser("run", help="Generate and show the morning brief")
    run.add_argument("--days", type=int, default=None)
    run.add_argument("--no-notify", action="store_true")
    run.add_argument("--no-llm", action="store_true")
    run.add_argument("--speak", action="store_true", help="Speak the brief aloud")
    run.add_argument("--no-speak", action="store_true", help="Do not speak, even if configured")

    collect_cmd = sub.add_parser("collect", help="Print raw brief data as JSON")
    collect_cmd.add_argument("--days", type=int, default=None)

    raw = sub.add_parser("raw", help="Print the plain-text brief without the LLM")
    raw.add_argument("--days", type=int, default=None)

    add = sub.add_parser("add", help="Add an appointment or reminder")
    add.add_argument("text")
    add.add_argument("--kind", choices=["appointment", "reminder"], default="reminder")
    add.add_argument("--due", help="ISO date, 'today 9am', 'tomorrow 14:30', or 'in 2h'")
    add.add_argument("--tag", action="append", default=[])

    listing = sub.add_parser("list", help="List upcoming items")
    listing.add_argument("--days", type=int, default=7)
    listing.add_argument("--all", action="store_true", help="Include completed items")
    listing.add_argument("--kind", choices=["appointment", "reminder"], default=None)

    for name, help_text in (
        ("done", "Mark an item complete"),
        ("remove", "Delete an item"),
    ):
        cmd = sub.add_parser(name, help=help_text)
        cmd.add_argument("id")

    snooze = sub.add_parser("snooze", help="Move an item to a new time")
    snooze.add_argument("id")
    snooze.add_argument("when", help="e.g. 30m, 2h, tomorrow 9am, 2026-11-25T09:00")

    sub.add_parser("clear-done", help="Remove completed items")
    sub.add_parser("json", help="Alias for collect")
    return parser


def main() -> int:
    args = build_parser().parse_args()
    cfg = load_config()
    command = args.command or "run"

    if command in ("collect", "json"):
        print(json.dumps(collect(cfg, getattr(args, "days", None)), indent=2))
        return 0

    if command == "raw":
        print(format_raw_brief(collect(cfg, args.days)))
        return 0

    if command == "run":
        data = collect(cfg, args.days)
        brief = format_raw_brief(data) if args.no_llm else call_llm(data, cfg)
        LATEST_PATH.write_text(brief + "\n")
        print(brief)
        if not args.no_notify and cfg.get("notify", True):
            send_notification(brief)
        voice_cfg = cfg.get("voice", {})
        should_speak = (
            not args.no_speak
            and (args.speak or voice_cfg.get("auto_speak_brief", False))
            and voice_cfg.get("enabled", True)
        )
        if should_speak:
            try:
                voice.speak(brief)
            except Exception as exc:
                print(f"warning: voice failed: {exc}", file=sys.stderr)
        return 0

    if command == "add":
        item = add_item(args.text, args.kind, args.due, args.tag)
        print(json.dumps(item_public(item), indent=2))
        return 0

    if command == "list":
        items = list_items(args.days, args.all, args.kind)
        print(json.dumps([item_public(item) for item in items], indent=2))
        return 0

    if command in ("done", "remove"):
        store = load_store()
        item = find_item(store, args.id)
        if not item:
            print(f"Item not found: {args.id}", file=sys.stderr)
            return 1
        if command == "done":
            item["done"] = True
            print(f"Done: {item['text']}")
        else:
            store["items"].remove(item)
            print(f"Removed: {item['text']}")
        save_store(store)
        return 0

    if command == "snooze":
        store = load_store()
        item = find_item(store, args.id)
        if not item:
            print(f"Item not found: {args.id}", file=sys.stderr)
            return 1
        item["due"] = parse_due(args.when).isoformat(timespec="seconds")
        item["done"] = False
        save_store(store)
        print(json.dumps(item_public(item), indent=2))
        return 0

    if command == "clear-done":
        store = load_store()
        before = len(store["items"])
        store["items"] = [item for item in store["items"] if not item.get("done")]
        save_store(store)
        print(f"Removed {before - len(store['items'])} completed items.")
        return 0

    build_parser().print_help()
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
