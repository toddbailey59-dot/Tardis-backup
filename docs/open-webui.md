# Local AI integrations

This adds two front ends to the local llama.cpp server:

1. **OpenCode** — local provider for coding
2. **Open WebUI** — ChatGPT-like browser page

The backend is the same OpenAI-compatible endpoint:

```text
http://127.0.0.1:8080/v1
```

Model: `qwen2.5-coder-7b` (Qwen2.5 Coder 7B Instruct Q4_K_M).

## OpenCode local provider

Config:

```text
~/.config/opencode/opencode.json
```

It defines a provider named `local` and sets it as the default model:

```text
local/qwen2.5-coder-7b
```

Verified with:

```sh
opencode run --model local/qwen2.5-coder-7b "Reply with exactly OK"
opencode run "Reply with exactly OK2"
```

You can still select other models with `/models` inside OpenCode.

## Open WebUI

Installed in a local uv-managed Python 3.12 venv:

```text
~/.local/share/open-webui/venv
```

Data:

```text
~/.local/share/open-webui/data
```

Service:

```text
~/.config/systemd/user/open-webui.service
```

It is enabled at login and listens only on localhost:

```text
http://127.0.0.1:3000
```

Open it in a browser with:

```sh
~/.local/bin/open-webui-ctl open
```

or press `SUPER + O`.

### Authentication

The service is configured with `WEBUI_AUTH=false`. Open WebUI auto-creates and
auto-signs-in a local admin account:

```text
admin@localhost / admin
```

Normally you should land straight in the chat UI. If you ever see a login page,
use those credentials.

The default and pinned model are set to `qwen2.5-coder-7b`.

### Controls

```sh
~/.local/bin/open-webui-ctl start
~/.local/bin/open-webui-ctl stop
~/.local/bin/open-webui-ctl restart
~/.local/bin/open-webui-ctl status
~/.local/bin/open-webui-ctl log
~/.local/bin/open-webui-ctl open
```

## Keybinds

| Key | Action |
| --- | --- |
| `SUPER + ALT + A` | Local AI terminal chat (`llama-chat` in Kitty) |
| `SUPER + G` | OpenCode in Kitty |
| `SUPER + O` | Open WebUI in the default browser |

## Verification

After a reboot, both services should be active:

```sh
systemctl --user status local-ai.service
systemctl --user status open-webui.service
curl http://127.0.0.1:8080/v1/models
curl http://127.0.0.1:3000/health
```
