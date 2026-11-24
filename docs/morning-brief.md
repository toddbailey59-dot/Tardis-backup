# TARDIS Morning Brief, Calendar and Voice

A local skill that gives the machine a morning routine and a calendar the local
AI can use. No cloud API keys are required for the brief, weather, news, agenda,
or voice.

## What is here

- `brief.py` — morning brief generator and shared agenda store
- `voice.py` — local Piper text-to-speech with a TARDIS persona
- `calendar_app.py` — small local calendar web app
- `openwebui_tool.py` — Open WebUI tool named `tardis_brief`
- `config.json` — locations, feeds, LLM endpoint, notification and voice settings
- `reminders.json` — shared appointments/reminders store
- `tardis-tool.jinja` — ChatML template that makes Qwen emit tool requests

Example sources:

- Weather: Open-Meteo, Harrow Ontario (`42.03339, -82.91654`)
- News: CBC Ontario, BBC World and a Google News search for Harrow Ontario
- LLM summary: local llama.cpp endpoint at `http://127.0.0.1:8080/v1`
- Voice: Piper `en_GB-alan-medium`, played through PulseAudio with `paplay`

## Morning brief CLI

```sh
~/.local/bin/morning-brief run                 # full brief + notification
~/.local/bin/morning-brief run --speak         # also read it aloud
~/.local/bin/morning-brief raw                 # plain text, no LLM
~/.local/bin/morning-brief collect             # raw JSON data
```

Press `SUPER + R` for a spoken brief on demand.

A systemd user timer runs the full brief daily at 07:00:

```sh
systemctl --user list-timers morning-brief.timer
systemctl --user status morning-brief.service
systemctl --user start morning-brief.service
```

## Agenda commands

```sh
~/.local/bin/morning-brief add "Dentist" --kind appointment --due "tomorrow 2pm"
~/.local/bin/morning-brief add "Bin night" --due "in 2h" --tag home
~/.local/bin/morning-brief list --days 7
~/.local/bin/morning-brief done <id>
~/.local/bin/morning-brief snooze <id> 30m
~/.local/bin/morning-brief remove <id>
```

Accepted times include ISO (`2026-11-25T14:00`), `today 9am`,
`tomorrow 14:30`, and `in 2h`.

## Calendar web app

```sh
~/.local/bin/tardis-calendar --host 127.0.0.1 --port 3010
```

Service:

```sh
systemctl --user status tardis-calendar.service
```

Open it with `SUPER + C` or:

```sh
xdg-open http://127.0.0.1:3010
```

The app, the CLI and the AI tool all read and write the same
`~/AI/morning-brief/reminders.json` store.

## Open WebUI tool

The tool id is `tardis_brief`. It is created and enabled through the Open WebUI
API and exposes:

- `get_morning_brief_data`
- `add_appointment`
- `add_reminder`
- `list_agenda`
- `complete_item`
- `snooze_item`
- `delete_item`
- `speak`

Example prompts in Open WebUI:

> Make me an appointment for tomorrow at 2pm for the dentist.

> Give me my morning brief and read it aloud.

> What is on my calendar this week?

Tool calls work because `local-ai-proxy` normalizes the local model's JSON tool
requests into OpenAI-style `tool_calls`. See `~/AI/local-ai/README.md`.

## Voice

```sh
~/.local/bin/tardis-voice "Good morning, Doctor. All systems are nominal."
~/.local/bin/tardis-voice --file ~/AI/morning-brief/latest.txt
~/.local/bin/tardis-voice "Standing by" --no-play --output /tmp/standby.wav
```

The persona is in the brief's system prompt. Spoken greetings and sign-offs are
chosen randomly from `voice.greetings` and `voice.signoffs` in `config.json`,
so the LLM does not duplicate them. The voice is fully local.
