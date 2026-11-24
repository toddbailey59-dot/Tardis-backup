# TARDIS Gold SDDM theme

Gold-on-navy login screen with a space panorama, animated gold glow, a
`POLICE BOX / T.A.R.D.I.S` badge, clock, session and layout selectors, and
reboot/power controls.

- Theme source: `~/.local/share/sddm/themes/tardis-gold`
- Installer/status helper: `~/bin/tardis-sddm`

Preview without changing the login screen:

```sh
~/bin/tardis-sddm test
```

Install for the next login (asks for sudo):

```sh
~/bin/tardis-sddm install
```

Revert the selection:

```sh
~/bin/tardis-sddm restore
```

The installer copies the theme to `/usr/share/sddm/themes/tardis-gold` and
writes `/etc/sddm.conf.d/99-tardis.conf`. It does not restart SDDM, so your
current session is not interrupted.
