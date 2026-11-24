# TARDIS fastfetch logo

`config.jsonc` uses the Kitty graphics protocol with `animationFrame: 0`, which
makes fastfetch play the animated GIF in Kitty terminals.

Files:

- `tardis.png` — original source artwork
- `tardis-gold.gif` — animated gold logo (36 frames, 12 fps, 3 second loop)

Regenerate the GIF after editing the source art:

```sh
~/bin/tardis-fastfetch-logo
```

The animation is a gentle gold glow pulse and sway, so it stays readable beside
the system information. If your terminal does not support the Kitty image
protocol, fastfetch falls back to its usual ASCII logo.
