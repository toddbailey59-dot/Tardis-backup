# TARDIS Gold Plymouth theme

Gold `ENTER TARDIS KEY` passphrase prompt and progress bar over the matching
space panorama. This is the boot splash shown after GRUB and before SDDM.

- Theme source: `~/.local/share/plymouth/themes/tardis-gold`
- Installer/status helper: `~/bin/tardis-plymouth`
- Asset rebuild helper: `~/bin/tardis-plymouth-theme`

Check the source assets:

```sh
~/bin/tardis-plymouth check
```

Install for the next boot (asks for sudo; rebuilds initramfs and grub.cfg):

```sh
~/bin/tardis-plymouth install
```

Revert the selection:

```sh
~/bin/tardis-plymouth restore
```

The installer backs up `/etc/mkinitcpio.conf`, `/etc/default/grub`, and the
existing initramfs before making changes.
