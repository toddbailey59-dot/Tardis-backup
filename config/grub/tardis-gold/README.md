# TARDIS Gold GRUB theme

A large gold `T.A.R.D.I.S` wordmark across a dark space panorama, with the
boot menu centered below it.

- Theme source: `~/.local/share/grub/themes/tardis-gold`
- Installer/status helper: `~/bin/tardis-grub`
- Asset rebuild helper: `~/bin/tardis-grub-theme`

Check the source assets:

```sh
~/bin/tardis-grub check
```

Install for the next boot (asks for sudo and regenerates `/boot/grub/grub.cfg`):

```sh
~/bin/tardis-grub install
```

Revert the selection:

```sh
~/bin/tardis-grub restore
```

The original `/etc/default/grub` is saved as
`/etc/default/grub.tardis-pre-theme` before installation.
