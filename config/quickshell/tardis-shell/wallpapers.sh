#!/bin/sh
# Emit one line per usable wallpaper pair: name|preview|current(0|1)

root="$HOME/Pictures/wallpapers/pairs"
state="$HOME/.local/state/tardis-wallpaper/current"
current=$(cat "$state" 2>/dev/null || true)

for dir in "$root"/*; do
    [ -d "$dir" ] || continue
    [ -f "$dir/left.jpg" ] || continue
    [ -f "$dir/right.jpg" ] || continue
    [ -f "$dir/preview.jpg" ] || continue

    name=$(basename "$dir")
    flag=0
    [ "$name" = "$current" ] && flag=1
    printf '%s|%s|%s\n' "$name" "$dir/preview.jpg" "$flag"
done
