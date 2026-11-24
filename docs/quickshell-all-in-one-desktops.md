# All-in-One Desktops Built on Quickshell

*Arch + Hyprland focus, checked Nov 2026. Quickshell is the QML/QtQuick toolkit; these are complete shell configs built with it — bar/panel, launcher, notifications, OSD, lock screen, settings, wallpaper, etc.*

> Install the toolkit first if an installer doesn't do it for you: `yay -S quickshell`
> (some projects explicitly need `quickshell-git` from the AUR).

---

## Quick comparison

| Project | Style | What it feels like | Install on current Arch | Effort / risk |
|---|---|---|---|---|
| **Omarchy** | Full bar + plugins | Complete distro desktop | ISO preferred; shell-only possible but fiddly | Low effort, high opinionation |
| **Caelestia** | Bar + panels | Polished GNOME-ish Material desktop | AUR `caelestia-shell` | Medium, cleanest upgrades |
| **eqSh** | Panel + notch | Apple-inspired, very flashy | `curl ... get \| bash` → `au run` | Medium, early project |
| **Lucid** | Islands / notch / full bar | Material 3 "whole ecosystem" | `git clone` + `./install.sh` | High, very invasive installer |
| **Panacea** | Single pill ("no bar") | Nothing OS / dynamic island | `git clone` + `./install.sh` | High, touches GRUB too |
| **k4** | Dynamic island → dock | Plugin-first, animation-heavy | `curl .../instalar \| sh` | Medium-high |
| **ekremx25/quickshell** | Traditional bar + dock | Feature kitchen sink, GUI settings | Interactive wizard installer | Medium-high, huge config |
| **illogical-impulse (ii-qs)** | Bar + sidebars | end_4's famous Material 3 rice | `bash <(curl -s https://ii.clsty.link/get)` | High, opinionated dotfiles |

**My shortlist for a basic Arch + Hyprland box:**
1. **Caelestia** if you want a real package you can AUR-upgrade and then tweak.
2. **ekremx25** if you want the most features and a GUI settings dashboard.
3. **Lucid** if you want the most complete "desktop" (own file manager, settings, screenshot tool, lock/login) and accept the installer taking over.
4. **Panacea / k4** if the island aesthetic is the whole point.
5. **Omarchy** only if you're happy running the distro, not just the shell.

---

## 1. Omarchy shell — the most complete, but it's a distro

A single long-running Quickshell instance hosts the whole desktop: bar, panels, overlays, menus and headless services are plugins. CLI tools talk to it over IPC (`omarchy-shell`, `omarchy bar`, `omarchy plugin`). Themes, keybinds, screenshots, clipboard, reminders and idle/screensaver are all first-party.

- **Pros:** Most coherent "just works" result; plugin manifest (`bar-widget`, `bar`, `panel`, `overlay`, `menu`, `service`); CLI-driven control and hot-reload; themes and bar layout are configurable without editing QML; frequent releases.
- **Cons:** Designed for the Omarchy ISO. Running the shell on stock Arch means tracking a checkout and its migrations (the docs discuss migration traps, including bootloader/kernel entries); strongly opinionated defaults; plugins run as unsandboxed code in the shell process.
- **Get it:** <https://omarchy.org/> (ISO). Shell-only from a `quattro` checkout is possible but not the supported happy path.

---

## 2. Caelestia shell — best AUR-packaged option

The shell half of the Caelestia dotfiles ecosystem. Widgets are Quickshell/QML, window manager is Hyprland, and a companion `caelestia-cli` exposes IPC (`caelestia shell ...`). Supports per-monitor config, D-Bus global shortcuts, clipboard, media, wallpapers, etc.

- **Pros:** Stable AUR package (`caelestia-shell`) plus `caelestia-shell-git`; clean separation shell vs. dotfiles vs. CLI; Home Manager module; documented IPC and shortcuts; good middle ground between "ready-made" and "hackable".
- **Cons:** Manual build wants `quickshell-git` (not the tagged release) and a long dependency list (`ddcutil`, `brightnessctl`, `cava`, `aubio`, `lm_sensors`, Qt6 extras…). Don't edit AUR-installed files if you want custom changes — use the manual install path. The full look comes from the separate dotfiles repo.
- **Get it:** `paru -S caelestia-shell caelestia-cli`, then `caelestia shell -d`. Docs: <https://github.com/caelestia-dots/shell>

---

## 3. eqSh — the flashy Apple-inspired one

"Panel, notch, launcher, notifications hub, lockscreen, wallpaper engine, tray, and more — all in one." Built on Quickshell, made for Hyprland, with a Settings app and AI "Sigrid" extras.

- **Pros:** Very cohesive visual design; notch + panel + lock screen + wallpaper engine in one; includes its own settings UI; actively maintained.
- **Cons:** Early project — community feedback praises looks but calls day-to-day usability still rough; nonstandard layout (`~/.local/share/equora`) and `au` CLI; smaller community/docs than Caelestia or Omarchy.
- **Get it:** `yay -S quickshell`, then `curl -fsSL https://eqsh-wiki.github.io/get | bash`, start with `au run` (or `exec-once = /usr/local/bin/au run`). Repo: <https://github.com/eq-desktop/eqsh>

---

## 4. Lucid — the full ecosystem (shell + apps + icons + lock/login)

Material 3 Expressive desktop for Arch + Hyprland 0.55+. Bar in islands/notch/full-strip form, dock/launcher, user-built control center, desktop widgets/icons, notifications/OSD, lock *and* login screen, plus its own apps: Lumen (files/dialogs), Lens (images), LucidShot (screenshots/recording), Settings, music lyrics/visualizer, phone via KDE Connect. Wallpaper drives one palette across GTK, Qt, KDE, kitty, VSCodium, etc.

- **Pros:** Closest thing to a complete DE without leaving Arch; GUI settings instead of config files; self-updating releases (v1.21.1 as of Nov 2026); consistent theming everywhere; edit mode for arranging widgets.
- **Cons:** Arch-only, Hyprland 0.55+; installer is *deep* — rewrites `hyprland.lua`, keybinds, layer rules, theming/templates, GTK/kitty/VSCodium looks, builds a Hyprland cursor plugin, can install SDDM and several GB of mostly-AUR apps. Backups exist and flags (`--no-apps`, `--no-hypr`, `--no-look`, `--no-plugins`) help, but this is a takeover, not a package.
- **Get it:** `git clone https://github.com/Sn3akyy1/lucid.git && cd lucid && ./install.sh`. Site: <https://sn3akyy1.github.io/lucid/>

---

## 5. Panacea — one pill instead of a bar

"No bar, no tray, no scattered popups." Everything lives in a capsule pinned to a screen edge: quick settings, Wi-Fi/Bluetooth, notifications, wallpaper carousel, workspaces, launcher, Launchpad grid, smart clipboard, files, media editor, recorder, password vault, battery, lock, power, settings. Also themes GRUB and can reboot into another OS from the launcher.

- **Pros:** Genuinely different and very cohesive; one geometry/palette/animation timeline; settings app with live mock-ups; Hyprland primary with Niri beta; smart clipboard and built-in file/password tools reduce separate apps.
- **Cons:** No conventional bar — a big workflow change; installer also touches GRUB/`os-prober` (flags like `--no-grub` exist); dotfiles-style maintenance; niche project.
- **Get it:** `git clone https://github.com/EnsixD/Panacea.git && cd Panacea && ./install.sh` (checks deps, offers to install `yay` since Quickshell is AUR-only). Repo: <https://github.com/EnsixD/Panacea>

---

## 6. k4 — dynamic island with a real plugin system

Collapsed island at an edge that expands into launcher, control center, notifications, clipboard, window switcher, theme panel, shortcut viewer. Everything — even the clock — is a plugin with isolated loading, permission declarations and pinned commits, discoverable/installable from the bar. Also: video/GIF wallpapers drawn by the shell (pauses when hidden), palette extraction, a built-in recorder + non-linear video editor, and a bar-that-becomes-a-dock transition.

- **Pros:** Best plugin architecture of the group; broken plugins don't kill the bar; rich media features in-shell; documented agent skill for writing plugins; dry-run installer.
- **Cons:** Arch + Hyprland only; installer writes Hyprland integration; a lot of bespoke machinery means more to learn when it breaks; animation-forward design isn't for minimalists.
- **Get it:** `curl -fsSL https://raw.githubusercontent.com/k4ditano/k4/main/instalar | sh` (run `./instalar --dry-run` first). Repo: <https://github.com/k4ditano/k4>

---

## 7. ekremx25/quickshell — maximum features, GUI configuration

Unfortunate name collision: this is a *config* built on Quickshell, not the framework. Top bar + animated dock + settings dashboard (drag-and-drop modules, seven layout presets, Material You editor) + OSD + notification center + tray + clipboard + workspace overview with live previews + app drawer + wallpaper picker + lock screen + network/Bluetooth/VPN managers + monitor/HDR controls + night light + audio EQ + weather/world clocks/markets/currency/night light… plus optional liquid-glass and popup animations.

- **Pros:** More built-in functionality than anything else here; settings GUI means less QML editing; compositor-agnostic (Hyprland, Niri, Mango); installer detects monitors, asks preferences and backs up existing install; `--dry-run`.
- **Cons:** Feature creep = larger breakage surface; depends on extras (`matugen`, `cava`, `hyprsunset`/`gammastep`, fonts); repo name makes docs/support searching confusing; still a personal config rather than a packaged product.
- **Get it:** `bash <(curl -qfsSL https://raw.githubusercontent.com/ekremx25/quickshell/main/install.sh)` (append `--dry-run` to preview). Repo: <https://github.com/ekremx25/quickshell>

---

## 8. illogical-impulse (end_4, Quickshell edition)

The Quickshell-based version of end_4's famous dotfiles (`ii-qs`). Design goals stated in their docs: Qt apps over GTK, Material Design 3, familiar Windows/GNOME-style keybinds, and unapologetic opinionatedness.

- **Pros:** The look people usually mean when they say "I want end_4's setup"; good docs with install/update/uninstall and configuration pages; Qt-native apps match the shell; translates well across languages.
- **Cons:** It's dotfiles — expect keybinds, app choices and file layout to be someone else's; installer/setup script changes a lot; switching to the Quickshell edition means leaving the older AGS version's ecosystem.
- **Get it:** `bash <(curl -s https://ii.clsty.link/get)` → clones to `~/.cache/dots-hyprland` and runs `./setup install`. Docs: <https://ii.clsty.link/en/ii-qs/00description/>

---

## Honourable mentions / not actually Quickshell

- **Noctalia** — full all-in-one shell (bar, dock, launcher, control center, notifications, lock, wallpaper, TOML config + IPC), but its README states it is built directly on Wayland/OpenGL ES with **no Qt or GTK dependency**. A separate Quickshell implementation (`noctalia-qs`) is used by some dotfiles. Great option if you don't actually need QML. <https://noctalia.dev/>
- **Caelestia dotfiles** — the rest of Caelestia's desktop (Hyprland config, apps, theme) that pairs with `caelestia-shell`.
- **nysh** — Quickshell/QML shell by nydragon, but explicitly "not necessarily meant to be used by others" and its control center / notification center are still TODO. Reference material, not a daily driver.
- **HyDE, ML4W, Omarchy (distro)** — full setups; only Omarchy's shell is Quickshell-based (HyDE is Waybar-based).

---

## Before you run any installer

1. Snapshot `~/.config` (especially `hypr/`, `quickshell/`) and know your reinstall path.
2. Use `--dry-run` / `-t` where offered: ekremx25, k4, Lucid's switches, Panacea.
3. Keep one known-good Hyprland config; every project here adds its own autostart and keybinds.
4. Most of these need an AUR helper (`yay`/`paru`) because Quickshell itself and several deps live in the AUR.

## Sources
- <https://quickshell.org/>
- <https://github.com/basecamp/omarchy/blob/quattro/docs/omarchy-shell.md>
- <https://github.com/caelestia-dots/shell>
- <https://github.com/eq-desktop/eqsh>
- <https://github.com/Sn3akyy1/lucid>
- <https://github.com/EnsixD/Panacea>
- <https://github.com/k4ditano/k4>
- <https://github.com/ekremx25/quickshell>
- <https://ii.clsty.link/en/ii-qs/00description/>
- <https://noctalia.dev/>
