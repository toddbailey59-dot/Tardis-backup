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

Authentication uses an HTTPS personal access token stored locally at
`~/.config/git/credentials` (mode `600`). The Git identity for commits is still
`newlife50 <newlife50@live.com>`.

The token currently belongs to GitHub account `toddbailey59-dot`, so the remote
is:

```text
https://github.com/toddbailey59-dot/tardis-backup.git
```

1. Create an empty GitHub repository named `tardis-backup` under
   `toddbailey59-dot`. Do not add a README, license, or `.gitignore`.
2. The token must have **Contents: read/write** on that repository.
3. Push:

   ```sh
   ~/tardis-backup/backup.sh "initial TARDIS backup" --push
   ```

To replace the stored token later:

```sh
~/tardis-backup/set-github-token.sh
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
