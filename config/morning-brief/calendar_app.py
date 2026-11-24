#!/usr/bin/env python3
"""Small local calendar web app sharing the TARDIS agenda store."""
from __future__ import annotations

import argparse
import json
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

import brief

HTML = r"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>TARDIS Calendar</title>
<style>
  :root {
    --bg: #0a1020;
    --panel: #101a30;
    --panel2: #15223c;
    --gold: #e5b64c;
    --blue: #22558f;
    --text: #efe5c6;
    --muted: #9fb0c9;
    --line: #2a3c5c;
  }
  * { box-sizing: border-box; }
  body {
    margin: 0; padding: 20px; color: var(--text);
    background: radial-gradient(circle at 20% 0%, #12224a 0, var(--bg) 55%);
    font: 14px "JetBrains Mono", "DejaVu Sans Mono", monospace;
  }
  h1 { color: var(--gold); letter-spacing: .12em; font-size: 20px; margin: 0 0 4px; }
  .sub { color: var(--muted); margin-bottom: 18px; font-size: 12px; }
  .layout { display: grid; grid-template-columns: minmax(0, 2fr) minmax(280px, 1fr); gap: 18px; }
  .card { background: var(--panel); border: 1px solid var(--line); border-radius: 12px; padding: 16px; }
  .card h2 { color: var(--gold); font-size: 13px; letter-spacing: .1em; margin: 0 0 12px; }
  .bar { display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px; }
  button {
    background: var(--blue); color: var(--text); border: 1px solid var(--line);
    border-radius: 6px; padding: 6px 10px; cursor: pointer; font: inherit;
  }
  button:hover { border-color: var(--gold); }
  .danger { background: #5a2230; }
  .grid { display: grid; grid-template-columns: repeat(7, 1fr); gap: 4px; }
  .dow { color: var(--muted); text-align: center; font-size: 11px; padding-bottom: 4px; }
  .day {
    min-height: 92px; background: var(--panel2); border: 1px solid var(--line);
    border-radius: 8px; padding: 5px; overflow: hidden;
  }
  .day.other { opacity: .38; }
  .day.today { border-color: var(--gold); }
  .num { color: var(--muted); font-size: 11px; }
  .chip {
    display: block; width: 100%; margin-top: 3px; padding: 2px 4px;
    border-radius: 4px; font-size: 10px; text-align: left; white-space: nowrap;
    overflow: hidden; text-overflow: ellipsis; border: 0;
  }
  .chip.appt { background: #22558f; color: #fff; }
  .chip.reminder { background: #6b5220; color: #fff5dc; }
  .chip.done { opacity: .45; text-decoration: line-through; }
  form label { display: block; color: var(--muted); font-size: 11px; margin: 8px 0 3px; }
  input, select {
    width: 100%; background: #0b1222; color: var(--text); border: 1px solid var(--line);
    border-radius: 6px; padding: 7px; font: inherit;
  }
  .row { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
  .actions { display: flex; gap: 8px; margin-top: 14px; }
  ul { list-style: none; padding: 0; margin: 0; }
  li { border-bottom: 1px solid var(--line); padding: 7px 0; }
  li:last-child { border-bottom: 0; }
  .meta { color: var(--gold); font-size: 11px; }
  .empty { color: var(--muted); font-size: 12px; }
</style>
</head>
<body>
<h1>TARDIS CALENDAR</h1>
<div class="sub">Shared agenda — the CLI, the AI, and this page all use the same store.</div>
<div class="layout">
  <div class="card">
    <div class="bar">
      <button id="prev">&larr; PREV</button>
      <strong id="month-label"></strong>
      <button id="next">NEXT &rarr;</button>
    </div>
    <div class="grid" id="dow"></div>
    <div class="grid" id="grid"></div>
  </div>
  <div>
    <div class="card">
      <h2>ADD ENTRY</h2>
      <form id="add-form">
        <label>Text</label>
        <input id="text" required placeholder="Dentist appointment">
        <div class="row">
          <div>
            <label>Type</label>
            <select id="kind">
              <option value="appointment">Appointment</option>
              <option value="reminder">Reminder</option>
            </select>
          </div>
          <div>
            <label>Tags (comma separated)</label>
            <input id="tags" placeholder="health, town">
          </div>
        </div>
        <div class="row">
          <div><label>Date</label><input id="date" type="date" required></div>
          <div><label>Time</label><input id="time" type="time" value="09:00"></div>
        </div>
        <div class="actions">
          <button type="submit">ADD</button>
          <button type="button" id="clear">CLEAR</button>
        </div>
      </form>
    </div>
    <div class="card" style="margin-top:18px">
      <h2>UPCOMING</h2>
      <ul id="upcoming"></ul>
    </div>
  </div>
</div>
<script>
const DOW = ['SUN','MON','TUE','WED','THU','FRI','SAT'];
let events = [];
let view = new Date();
view = new Date(view.getFullYear(), view.getMonth(), 1);

function esc(s) { return String(s).replace(/[&<>"]/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c])); }
function isoDate(d) {
  const p = n => String(n).padStart(2, '0');
  return d.getFullYear() + '-' + p(d.getMonth()+1) + '-' + p(d.getDate());
}
function api(path, options) {
  return fetch(path, options).then(r => r.json());
}
function load() {
  api('/api/events?days=120&include_done=true').then(data => {
    events = data.items || [];
    render();
  });
}
function render() {
  document.getElementById('dow').innerHTML = DOW.map(d => '<div class="dow">'+d+'</div>').join('');
  const y = view.getFullYear(), m = view.getMonth();
  document.getElementById('month-label').textContent =
    view.toLocaleString(undefined, {month:'long', year:'numeric'}).toUpperCase();
  const first = new Date(y, m, 1);
  const start = first.getDay();
  const days = new Date(y, m+1, 0).getDate();
  const today = isoDate(new Date());
  let html = '';
  for (let i = 0; i < 42; i++) {
    const dayNum = i - start + 1;
    const d = new Date(y, m, dayNum);
    const key = isoDate(d);
    const other = d.getMonth() !== m ? ' other' : '';
    const mark = key === today ? ' today' : '';
    const items = events.filter(e => e.due && e.due.slice(0,10) === key);
    html += '<div class="day'+other+mark+'" data-date="'+key+'"><span class="num">'+d.getDate()+'</span>';
    items.slice(0,3).forEach(e => {
      const cls = (e.kind === 'appointment' ? 'appt' : 'reminder') + (e.done ? ' done' : '');
      html += '<button class="chip '+cls+'" title="'+esc(e.text)+'" onclick="pick(\''+e.id+'\')">'+
              esc(e.due.slice(11,16))+' '+esc(e.text)+'</button>';
    });
    if (items.length > 3) html += '<span class="num">+'+(items.length-3)+' more</span>';
    html += '</div>';
  }
  document.getElementById('grid').innerHTML = html;

  const now = Date.now();
  const upcoming = events.filter(e => !e.done && e.due && new Date(e.due).getTime() >= now - 86400000)
                         .sort((a,b) => a.due.localeCompare(b.due)).slice(0,12);
  document.getElementById('upcoming').innerHTML = upcoming.length ? upcoming.map(e =>
    '<li><div class="meta">'+esc(e.due_label)+' · '+esc(e.kind)+'</div>'+esc(e.text)+
    ' <button onclick="act(\''+e.id+'\',\'done\')">DONE</button>'+
    ' <button class="danger" onclick="act(\''+e.id+'\',\'remove\')">DEL</button></li>'
  ).join('') : '<div class="empty">Nothing upcoming.</div>';
}
function pick(id) {
  const e = events.find(x => x.id === id);
  if (!e) return;
  document.getElementById('text').value = e.text;
  document.getElementById('kind').value = e.kind;
  document.getElementById('date').value = e.due.slice(0,10);
  document.getElementById('time').value = e.due.slice(11,16);
  document.getElementById('tags').value = (e.tags||[]).join(', ');
}
function act(id, action) {
  api('/api/events/'+id+'/'+action, {method:'POST'}).then(load);
}
document.getElementById('prev').onclick = () => {
  view = new Date(view.getFullYear(), view.getMonth()-1, 1); render();
};
document.getElementById('next').onclick = () => {
  view = new Date(view.getFullYear(), view.getMonth()+1, 1); render();
};
document.getElementById('clear').onclick = () => {
  document.getElementById('add-form').reset();
  document.getElementById('date').value = isoDate(new Date());
  document.getElementById('time').value = '09:00';
};
document.getElementById('add-form').onsubmit = ev => {
  ev.preventDefault();
  const due = document.getElementById('date').value + 'T' + document.getElementById('time').value;
  const payload = {
    text: document.getElementById('text').value,
    kind: document.getElementById('kind').value,
    due: due,
    tags: document.getElementById('tags').value.split(',').map(s=>s.trim()).filter(Boolean)
  };
  api('/api/events', {method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(payload)})
    .then(() => { document.getElementById('text').value=''; document.getElementById('tags').value=''; load(); });
};
document.getElementById('date').value = isoDate(new Date());
load();
</script>
</body>
</html>
"""


class Handler(BaseHTTPRequestHandler):
    server_version = "TARDISCalendar/1.0"

    def log_message(self, fmt: str, *args) -> None:
        print(f"calendar: {fmt % args}", file=sys.stderr)

    def _send(self, status: int, body: bytes, content_type: str) -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, DELETE, OPTIONS")
        self.end_headers()
        self.wfile.write(body)

    def _json(self, status: int, payload) -> None:
        self._send(status, json.dumps(payload, indent=2).encode(), "application/json")

    def _body(self) -> dict:
        length = int(self.headers.get("Content-Length", 0))
        if not length:
            return {}
        try:
            return json.loads(self.rfile.read(length))
        except Exception:
            return {}

    def do_OPTIONS(self) -> None:
        self._send(204, b"", "text/plain")

    def do_GET(self) -> None:
        parsed = urlparse(self.path)
        if parsed.path == "/":
            self._send(200, HTML.encode(), "text/html; charset=utf-8")
            return
        if parsed.path == "/api/health":
            self._json(200, {"status": True, "service": "tardis-calendar"})
            return
        if parsed.path == "/api/events":
            query = parse_qs(parsed.query)
            days = int(query.get("days", ["60"])[0])
            include_done = query.get("include_done", ["false"])[0].lower() == "true"
            items = brief.list_items(days=days, include_done=include_done)
            self._json(200, {"items": [brief.item_public(item) for item in items]})
            return
        self._json(404, {"detail": "Not found"})

    def do_POST(self) -> None:
        parsed = urlparse(self.path)
        path = parsed.path
        if path == "/api/events":
            data = self._body()
            try:
                item = brief.add_item(
                    data.get("text", ""),
                    data.get("kind", "reminder"),
                    data.get("due"),
                    data.get("tags", []),
                )
                self._json(201, brief.item_public(item))
            except ValueError as exc:
                self._json(400, {"detail": str(exc)})
            return
        if path.startswith("/api/events/") and path.endswith("/done"):
            item_id = path.split("/")[3]
            store = brief.load_store()
            item = brief.find_item(store, item_id)
            if not item:
                self._json(404, {"detail": "Not found"})
                return
            item["done"] = True
            brief.save_store(store)
            self._json(200, brief.item_public(item))
            return
        if path.startswith("/api/events/") and path.endswith("/snooze"):
            item_id = path.split("/")[3]
            data = self._body()
            store = brief.load_store()
            item = brief.find_item(store, item_id)
            if not item:
                self._json(404, {"detail": "Not found"})
                return
            try:
                item["due"] = brief.parse_due(data.get("when", "1h")).isoformat(timespec="seconds")
            except ValueError as exc:
                self._json(400, {"detail": str(exc)})
                return
            item["done"] = False
            brief.save_store(store)
            self._json(200, brief.item_public(item))
            return
        self._json(404, {"detail": "Not found"})

    def do_DELETE(self) -> None:
        parsed = urlparse(self.path)
        if parsed.path.startswith("/api/events/"):
            item_id = parsed.path.split("/")[3]
            store = brief.load_store()
            item = brief.find_item(store, item_id)
            if not item:
                self._json(404, {"detail": "Not found"})
                return
            store["items"].remove(item)
            brief.save_store(store)
            self._json(200, {"removed": item_id})
            return
        self._json(404, {"detail": "Not found"})


def main() -> int:
    parser = argparse.ArgumentParser(description="TARDIS local calendar")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=3010)
    args = parser.parse_args()
    server = ThreadingHTTPServer((args.host, args.port), Handler)
    print(f"TARDIS calendar on http://{args.host}:{args.port}", file=sys.stderr)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
