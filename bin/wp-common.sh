#!/bin/sh
# Shared helpers for the TARDIS dual-monitor wallpaper pairs.

WALL_ROOT="$HOME/Pictures/wallpapers/pairs"
STATE_DIR="$HOME/.local/state/tardis-wallpaper"
STATE_FILE="$STATE_DIR/current"
LEFT_MONITOR="DP-3"
RIGHT_MONITOR="HDMI-A-1"

list_pairs() {
    find "$WALL_ROOT" -mindepth 1 -maxdepth 1 -type d -name 'space-*' |
        while read -r dir; do
            if [ -f "$dir/left.jpg" ] && [ -f "$dir/right.jpg" ]; then
                basename "$dir"
            fi
        done | sort
}

current_pair() {
    pair=$(cat "$STATE_FILE" 2>/dev/null || true)
    if [ -z "$pair" ] || [ ! -d "$WALL_ROOT/$pair" ]; then
        if [ -d "$WALL_ROOT/space-rosette" ]; then
            pair="space-rosette"
        else
            pair=$(list_pairs | head -n 1)
        fi
    fi
    printf '%s' "$pair"
}

write_configs() {
    pair=$1
    dir="$WALL_ROOT/$pair"

    mkdir -p "$STATE_DIR"
    printf '%s\n' "$pair" > "$STATE_FILE"

    cat > "$HOME/.config/hypr/hyprpaper.conf" <<EOF
ipc = 1
splash = 0

wallpaper {
    monitor = $LEFT_MONITOR
    path = $dir/left.jpg
    fit_mode = cover
}

wallpaper {
    monitor = $RIGHT_MONITOR
    path = $dir/right.jpg
    fit_mode = cover
}
EOF

    sed -i "s|^    path = .*/pairs/.*/left.jpg\$|    path = $dir/left.jpg|" \
        "$HOME/.config/hypr/hyprlock.conf"
    sed -i "s|^    path = .*/pairs/.*/right.jpg\$|    path = $dir/right.jpg|" \
        "$HOME/.config/hypr/hyprlock.conf"
}

apply_pair() {
    pair=$1
    dir="$WALL_ROOT/$pair"

    write_configs "$pair"

    hyprctl hyprpaper unload all >/dev/null 2>&1 || true
    hyprctl hyprpaper wallpaper "$LEFT_MONITOR, $dir/left.jpg, cover" >/dev/null 2>&1 || true
    hyprctl hyprpaper wallpaper "$RIGHT_MONITOR, $dir/right.jpg, cover" >/dev/null 2>&1 || true
}
