# TARDIS fastfetch logo

`~/bin/fastfetch` replaces a plain `fastfetch` call in Kitty with an animated
text logo that spells out `T.A.R.D.I.S` inside a gold `POLICE BOX` frame. It
uses only terminal text and cursor movement — no Kitty graphics protocol, no
image transmissions, and no `i=…;OK` replies.

The system information is printed once. Each frame is redrawn in place while
the rest of the screen is left alone, so there is no per-frame flicker. The
highlight moves forward through the letters, back again, then settles on an
all-gold frame.

Files:

- `tardis-text-frames` — 11 animation frames used by `~/bin/fastfetch`
- `tardis-text-logo.txt` — static version used by fastfetch outside Kitty
- `tardis.png`, `tardis-gold.gif`, `tardis-gold.png`, `tardis-spin.gif` — legacy image assets, no longer required

Regenerate the text frames and static logo:

```sh
~/bin/tardis-fastfetch-text-logo
```

Calling `fastfetch` with arguments still runs `/usr/bin/fastfetch` normally,
using the static text logo from `config.jsonc`.
