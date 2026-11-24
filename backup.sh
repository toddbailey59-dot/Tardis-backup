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
    "$REPO/config/opencode" \
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
for f in llama-server llama-cli llama-chat local-ai open-webui-ctl; do
    cp -a "$SRC/.local/bin/$f" "$REPO/bin/" 2>/dev/null || true
done
for f in local-ai.service open-webui.service; do
    cp -a "$SRC/.config/systemd/user/$f" "$REPO/config/systemd-user/" 2>/dev/null || true
done
cp -a "$SRC/AI/local-ai/README.md" "$REPO/docs/local-ai.md" 2>/dev/null || true
cp -a "$SRC/AI/open-webui/README.md" "$REPO/docs/open-webui.md" 2>/dev/null || true

# OpenCode local provider config (auth/service secrets are not copied)
cp -a "$SRC/.config/opencode/opencode.json" "$REPO/config/opencode/" 2>/dev/null || true

# VS Code workspace, settings, custom theme
cp -a "$SRC/Code/tardis.code-workspace" "$REPO/config/code/" 2>/dev/null || true
cp -a "$SRC/Code/README.md" "$REPO/config/code/" 2>/dev/null || true
cp -a "$SRC/.config/Code - OSS/User/settings.json" "$REPO/config/code-user/" 2>/dev/null || true
cp -a "$SRC/.vscode-oss/extensions/doctor.tardis-theme-0.0.1/." "$REPO/config/vscode-theme/" 2>/dev/null || true

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
