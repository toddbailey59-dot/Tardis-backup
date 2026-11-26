# TARDIS Shell

Fresh Quickshell desktop shell for the Arch + Hyprland TARDIS setup. It replaces
Waybar and dunst with a single shell process and keeps the existing keybind
semantics.

## Launch

Hyprland autostarts it from `~/.config/hypr/doctor.lua`:

```sh
quickshell -p /home/doctor/.config/quickshell/tardis-shell
```

The explicit `-p` path is required because the IPC calls also use it.

## Keybinds

| Keys | Action |
| --- | --- |
| `SUPER + A` | Application launcher |
| `SUPER + D` | Quick settings / volume / DND |
| `SUPER + N` | Notification center |
| `SUPER + K` | Power menu |
| `SUPER + SHIFT + V` | Clipboard history |
| `SUPER + I` | JARVIS / OpenCode panel |
| `SUPER + H` | Keybinds overlay |
| `SUPER + TAB` | Workspace overview, cycle forward |
| `SUPER + SHIFT + TAB` | Workspace overview, cycle backward |
| `SUPER + G` | Floating OpenCode terminal session |
| `SUPER + ALT + A` | Local AI chat in Kitty (llama-chat) |
| `SUPER + O` | Open WebUI in the default browser |
| `SUPER + C` | TARDIS calendar in the default browser |
| `SUPER + R` | Spoken TARDIS morning brief |
| `SUPER + SHIFT + E` | VS Code (TARDIS workspace) |
| `Print` / `SHIFT + Print` | Full / region screenshot |

All other binds remain unchanged in `~/.config/hypr/keybinds.txt` and
`~/.config/hypr/doctor.lua`.

## Application icons

The launcher uses Qt's `hicolor` theme. Your user-level
`~/.local/share/icons/hicolor/index.theme` inherits `Papirus-Dark`, so app
icons are complete and consistent. To install or refresh them:

```sh
~/bin/tardis-icons install
~/bin/tardis-icons status
```

The icon theme data is large and is not stored in the git backup; the installer
script and Qt appearance config are.

## Settings

GUI: click the gear in the top bar, or use the `SETTINGS` button in quick
settings.

CLI:

```sh
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis settingsList
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis settingsGet barHeight
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis settingsSet barHeight 40
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis settingsReset
```

Settings are stored in `settings.json` next to this README. Available keys:
`accent`, `barHeight`, `cornerRadius`, `barOpacity`, `launcherColumns`,
`popupTimeout`, `clock24h`, `clockSeconds`, `showWindowTitle`,
`showWorkspaceNumbers`, `dnd`, `animate`, `showSysStats`, `showWeather`,
`weatherLat`, `weatherLon`, `weatherUnit`, `weatherRefresh`,
`wallpaperSlideshow`, `wallpaperSlideshowMinutes`.

Weather is set to Harrow, Ontario (`42.03339, -82.91654`) in °C. Change it with:

```sh
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis settingsSet weatherLat 42.03339
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis settingsSet weatherLon -82.91654
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis settingsSet weatherUnit C
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis reloadShell
```

Weather comes from Open-Meteo (no API key). System stats are read from
`/proc/loadavg`, `free`, and hwmon/thermal sysfs nodes.

## IPC

```sh
qs ipc -p /home/doctor/.config/quickshell/tardis-shell show
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis toggleLauncher
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis togglePower
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis toggleNotifications
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis toggleQuick
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis toggleClipboard
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis toggleChat
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis toggleHelp
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis overviewCycle
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis overviewCycleBack
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis closeOverlays
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis reloadShell
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis statsInfo
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis statsRefresh
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis wallpaperNext
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis wallpaperInfo
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis toggleWallpaperGallery
```

## Notes

- Bars are created per monitor; workspace buttons are filtered to that monitor.
- Hovering a bar widget (workspace, title, weather, stats, audio, notifications,
  clock, gear) shows a pill-shaped tooltip just below the bar with details about
  that indicator.
- The shell owns `org.freedesktop.Notifications`; dunst is killed at startup.
- Volume/mute changes raise a brief notification (suppressed when DND is on).
- Live workspace previews use `ScreencopyView`.
- The wallpaper gallery enumerates pairs with `wallpapers.sh` and applies the
  selected pair through `~/bin/wp-apply` (dual-monitor, one IPC call each).
- The two icon warnings for `applications-system` and
  `preferences-system-network` come from missing icon-theme entries and are
  cosmetic.
