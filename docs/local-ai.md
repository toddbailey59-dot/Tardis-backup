# Local AI

Local LLM setup using llama.cpp with Vulkan on the Radeon RX 580.

## Hardware

- AMD Ryzen Threadripper 1920X, 12 cores / 24 threads
- 31 GiB RAM
- Radeon RX 580, 8 GiB VRAM
- Vulkan via RADV (`vulkan-radeon`)

## Installed

- llama.cpp build `b12675` in `~/.local/lib/llama.cpp`
- Model: `qwen2.5-coder-7b-instruct-q4_k_m.gguf` (~4.36 GiB)
- Wrappers in `~/.local/bin/`:
  - `llama-cli`, `llama-server`
  - `llama-chat` — interactive terminal chat
  - `local-ai` — service/API control

## Start the API server

```sh
~/.local/bin/local-ai start
```

The OpenAI-compatible endpoint is:

```text
http://127.0.0.1:8080/v1
```

Enable it at login:

```sh
~/.local/bin/local-ai enable
```

## Chat in the terminal

```sh
~/.local/bin/local-ai chat
```

Or directly:

```sh
~/.local/bin/llama-chat
```

## One-shot question

```sh
~/.local/bin/local-ai ask "Write a Python function to merge two dicts"
```

## Check the server

```sh
~/.local/bin/local-ai models
~/.local/bin/local-ai status
~/.local/bin/local-ai log
```

## Service files

```text
~/.config/systemd/user/local-ai.service
~/.config/systemd/user/local-ai-proxy.service
```

`local-ai.service` runs llama.cpp on `127.0.0.1:8081` with `--n-gpu-layers 99`,
so the model is fully offloaded to the RX 580 via Vulkan. It uses a 16K context
with q8 KV cache and the ChatML tool template at
`~/AI/morning-brief/tardis-tool.jinja`.

`local-ai-proxy.service` exposes the public OpenAI-compatible endpoint on
`127.0.0.1:8080`. It normalizes the local model's JSON tool requests into
proper `tool_calls`, which makes OpenCode and Open WebUI tools work reliably.

`~/.local/bin/local-ai {start|stop|restart|enable|status|log}` manages both services.

## Adding models

Download GGUF files into:

```text
~/.local/share/llama-models/
```

Then point `LOCAL_AI_MODEL` at one for `llama-chat`, or edit
`~/.config/systemd/user/local-ai.service` to change the server model.

## Front ends

- OpenCode local provider and Open WebUI are documented in
  `~/AI/open-webui/README.md`.
- `SUPER + ALT + A` opens `llama-chat` in Kitty.
- `SUPER + O` opens Open WebUI at `http://127.0.0.1:3000`.
