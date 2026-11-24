# TARDIS fastfetch logo

In Kitty, `~/bin/fastfetch` takes over plain `fastfetch` calls and animates the
gold TARDIS logo beside the system information. It uses Kitty's direct file
graphics protocol, because fastfetch's own `kitty` image type falls back to
ASCII on this build.

Files:

- `tardis.png` — original source artwork
- `tardis-gold.gif` — animated gold logo (36 frames, 12 fps, 3 second loop)
- `tardis-gold.png` — static first frame, used as the fallback logo

Regenerate the GIF and static frame:

```sh
~/bin/tardis-fastfetch-logo
```

Frame PNGs are cached in `~/.local/share/tardis-fastfetch/frames` and rebuilt
automatically if missing.

Outside Kitty, or when fastfetch is called with arguments, the real
`/usr/bin/fastfetch` runs normally.
