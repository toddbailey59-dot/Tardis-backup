#!/bin/sh
# Copy the live TARDIS configuration into this repo and commit it.
# Usage: ./backup.sh ["message"] [--push]

set -eu

REPO=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SRC="$HOME"

PUSH=0
MSG=""
for arg in "$@"; do
    case "$arg" in
        --push) PUSH=1 ;;
        *) MSG="$arg" ;;
    esac
done

rm -rf \
    "$REPO/config" \
    "$REPO/bin" \
    "$REPO/docs" \
    "$REPO/wallpapers" \
    "$REPO/state"

mkdir -p \
    "$REPO/config/quickshell" \
    "$REPO/config/hypr" \
    "$REPO/config/code" \
    "$REPO/config/code-user" \
    "$REPO/config/vscode-theme" \
    "$REPO/config/kitty" \
    "$REPO/config/fastfetch" \
    "$REPO/config/qt6ct" \
    "$REPO/config/opencode" \
    "$REPO/config/local-ai" \
    "$REPO/config/morning-brief" \
    "$REPO/config/systemd-user" \
    "$REPO/bin" \
    "$REPO/docs" \
    "$REPO/wallpapers" \
    "$REPO/state"

# Quickshell TARDIS shell
cp -a "$SRC/.config/quickshell/tardis-shell" "$REPO/config/quickshell/"

# Curated Hyprland files (no backups or stale .bak files)
for f in doctor.lua hyprland.lua hyprlock.conf hyprpaper.conf keybinds.txt monitors.lua workspaces.lua tardis_shutdown.sh; do
    if [ -f "$SRC/.config/hypr/$f" ]; then
        cp -a "$SRC/.config/hypr/$f" "$REPO/config/hypr/$f"
    fi
done

# Helper scripts
if [ -d "$SRC/bin" ]; then
    cp -a "$SRC/bin/." "$REPO/bin/"
fi

# Local AI wrappers and services (models, binaries, venv and WebUI data are excluded)
for f in llama-server llama-cli llama-chat local-ai open-webui-ctl morning-brief tardis-voice tardis-calendar tardis-tool-proxy; do
    cp -a "$SRC/.local/bin/$f" "$REPO/bin/" 2>/dev/null || true
done
for f in local-ai.service local-ai-proxy.service open-webui.service morning-brief.service morning-brief.timer tardis-calendar.service; do
    cp -a "$SRC/.config/systemd/user/$f" "$REPO/config/systemd-user/" 2>/dev/null || true
done
cp -a "$SRC/AI/local-ai/README.md" "$REPO/docs/local-ai.md" 2>/dev/null || true
cp -a "$SRC/AI/open-webui/README.md" "$REPO/docs/open-webui.md" 2>/dev/null || true
cp -a "$SRC/AI/morning-brief/README.md" "$REPO/docs/morning-brief.md" 2>/dev/null || true

# Local AI tool template and compatibility proxy (models and venvs are excluded)
for f in tool_proxy.py; do
    cp -a "$SRC/AI/local-ai/$f" "$REPO/config/local-ai/" 2>/dev/null || true
done

# Morning brief / calendar / voice skill (venv and generated audio are excluded)
for f in brief.py voice.py calendar_app.py openwebui_tool.py config.json reminders.json qwen2.5-tool.jinja tardis-tool.jinja README.md; do
    cp -a "$SRC/AI/morning-brief/$f" "$REPO/config/morning-brief/" 2>/dev/null || true
done

# OpenCode local provider config (auth/service secrets are not copied)
cp -a "$SRC/.config/opencode/opencode.json" "$REPO/config/opencode/" 2>/dev/null || true

# VS Code workspace, settings, custom theme
cp -a "$SRC/Code/tardis.code-workspace" "$REPO/config/code/" 2>/dev/null || true
cp -a "$SRC/Code/README.md" "$REPO/config/code/" 2>/dev/null || true
cp -a "$SRC/.config/Code - OSS/User/settings.json" "$REPO/config/code-user/" 2>/dev/null || true
cp -a "$SRC/.vscode-oss/extensions/doctor.tardis-theme-0.0.1/." "$REPO/config/vscode-theme/" 2>/dev/null || true

# Kitty terminal config
cp -a "$SRC/.config/kitty/kitty.conf" "$REPO/config/kitty/" 2>/dev/null || true

# fastfetch config and animated text TARDIS logo (rebuild with bin/tardis-fastfetch-text-logo)
for f in config.jsonc README.md tardis-text-frames tardis-text-logo.txt; do
    cp -a "$SRC/.config/fastfetch/$f" "$REPO/config/fastfetch/" 2>/dev/null || true
done

# Qt appearance (the Papirus icon data itself is restored by bin/tardis-icons)
cp -a "$SRC/.config/qt6ct/qt6ct.conf" "$REPO/config/qt6ct/" 2>/dev/null || true

# Research/docs
cp -a "$SRC/hyprland-desktop-shells.md" "$REPO/docs/" 2>/dev/null || true
cp -a "$SRC/quickshell-all-in-one-desktops.md" "$REPO/docs/" 2>/dev/null || true

# Wallpaper metadata only (no large JPEGs)
cp -a "$SRC/Pictures/wallpapers/README.md" "$REPO/wallpapers/" 2>/dev/null || true
cp -a "$SRC/.local/state/tardis-wallpaper/current" "$REPO/state/wallpaper-current" 2>/dev/null || true

cd "$REPO"
git add -A

if git diff --cached --quiet; then
    echo "No changes to commit."
else
    if [ -z "$MSG" ]; then
        MSG="Backup TARDIS $(date '+%Y-%m-%d %H:%M:%S')"
    fi
    git commit -m "$MSG"
fi

if [ "$PUSH" -eq 1 ]; then
    if git remote get-url origin >/dev/null 2>&1; then
        git push
    else
        echo "No origin remote configured." >&2
        exit 1
    fi
fi
