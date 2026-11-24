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
| `SUPER + SHIFT + E` | VS Code (TARDIS workspace) |
| `Print` / `SHIFT + Print` | Full / region screenshot |

All other binds remain unchanged in `~/.config/hypr/keybinds.txt` and
`~/.config/hypr/doctor.lua`.

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

Weather defaults to Detroit (`42.3314, -83.0458`) in °F because the machine
timezone is `US/Michigan`. Change it with:

```sh
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis settingsSet weatherLat 42.3314
qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis settingsSet weatherLon -83.0458
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
```

## Notes

- Bars are created per monitor; workspace buttons are filtered to that monitor.
- The shell owns `org.freedesktop.Notifications`; dunst is killed at startup.
- Volume/mute changes raise a brief notification (suppressed when DND is on).
- Live workspace previews use `ScreencopyView`.
- The two icon warnings for `applications-system` and
  `preferences-system-network` come from missing icon-theme entries and are
  cosmetic.
