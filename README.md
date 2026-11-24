# TARDIS Backup

Git-backed snapshot of the TARDIS desktop configuration.

## Included

- `config/quickshell/tardis-shell/` — Quickshell shell source and settings
- `config/hypr/` — Hyprland, hyprpaper, hyprlock, keybinds, workspaces
- `bin/` — wallpaper helper scripts
- `config/code/` — VS Code workspace
- `config/code-user/` — VS Code user settings
- `config/vscode-theme/` — custom TARDIS Dark theme
- `docs/` — research notes
- `wallpapers/README.md` — wallpaper pair documentation
- `state/wallpaper-current` — active wallpaper pair name

Large wallpaper JPEGs are intentionally not tracked. Re-download notes are in
`wallpapers/README.md`.

## Usage

Refresh the snapshot and commit:

```sh
~/tardis-backup/backup.sh
```

Commit and push to GitHub:

```sh
~/tardis-backup/backup.sh "update bar" --push
```

Or push the latest commit manually:

```sh
git -C ~/tardis-backup push
```

## GitHub setup

1. Add this SSH public key to GitHub → Settings → SSH and GPG keys:

   ```text
   ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPq/X2JtblJl0WT8g1AsvvLFA0/QV/TvrD7BJFJK9ap newlife50@live.com
   ```

2. Create an empty GitHub repository named `tardis-backup`.
3. The `origin` remote is preset to:

   ```text
   git@github.com:newlife50/tardis-backup.git
   ```

4. Test authentication:

   ```sh
   ssh -T git@github.com
   ```

5. Push:

   ```sh
   ~/tardis-backup/backup.sh "initial TARDIS backup" --push
   ```

## Restore

Copy a path back from the repo to its live location, for example:

```sh
cp -a ~/tardis-backup/config/quickshell/tardis-shell/. ~/.config/quickshell/tardis-shell/
cp -a ~/tardis-backup/config/hypr/doctor.lua ~/.config/hypr/doctor.lua
cp -a ~/tardis-backup/bin/. ~/bin/
```

Then reload:

```sh
hyprctl reload
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis reloadShell
```
