# TARDIS dual-monitor wallpapers

Hyprpaper cannot crop one image across separate outputs, so each wallpaper is
prepared as a full 3360×1050 panorama and split into two 1680×1050 halves.
The left half goes to `DP-3`, the right half to `HDMI-A-1`, producing one
continuous image across both monitors.

## Pairs

- `space-rosette` — Rosette Nebula (default)
- `space-w39` — W39 star-forming region
- `space-whirlpool` — Whirlpool Galaxy
- `space-m81m82` — M81 / M82
- `space-arp142` — Arp 142

Each pair directory contains:

- `panorama.jpg` — full 3360×1050 image
- `left.jpg`, `right.jpg` — the monitor halves
- `preview.jpg` — small overview
- `name.txt` — pair name

Originals are kept in `space-originals/`.

## Controls

- `SUPER + W` — next pair
- `SUPER + SHIFT + W` — wofi gallery
- Shell settings — **Wallpaper slideshow** toggle and interval (default: on, 5 min)

The slideshow runs from the Quickshell timer and calls `~/bin/wp-next`.

Manual commands:

```sh
~/bin/wp-next
~/bin/wp-select
~/bin/wp-apply space-rosette
```

The active pair is stored in `~/.local/state/tardis-wallpaper/current`.
Applying a pair also updates `~/.config/hypr/hyprpaper.conf` and
`~/.config/hypr/hyprlock.conf`, so the lock screen matches.
