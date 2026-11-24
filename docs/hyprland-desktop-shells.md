# Hyprland Desktop Shells — Pros & Cons

*Arch Linux + Hyprland, reference list current to Nov 2026.*

Hyprland is only the compositor. A **desktop shell** is the layer on top that gives you the
stuff a normal DE bundles: a status bar/panel, app launcher, notifications, lock screen,
OSD (volume/brightness), power menu, and often a dock or overview.

---

## TL;DR — where to start

| Goal | Best pick |
|---|---|
| "Just make my basic setup usable" | **Waybar** + `rofi-wayland` + `swaync` + `hyprlock`/`hypridle` |
| "Give me a full desktop without reinstalling Arch" | **HyDE** (installer script) |
| "I want to build a beautiful custom shell" | **AGS** (JS/TS) or **Quickshell** (QML) |
| "I want a polished distro that just works" | **Omarchy** (full Arch-based distro, Quickshell shell) |

---

## 1. Ready-made status bars / panels
Configuration is mostly JSON/TOML + CSS. Little to no programming.

### Waybar — the de-facto standard
- **Stack:** C++, GTK, JSON config + CSS
- **Install:** `sudo pacman -S waybar`
- **Pros:** Most mature and best-documented; native `hyprland/workspaces` module; huge
  community so almost any question has an answer; tons of scripts/examples; easy to theme.
- **Cons:** Config gets verbose fast; limited logic (no real conditionals/state); popups/menus
  are bolted on; needs separate tools for launcher/notifications/lock; can get heavy with
  many polling modules.

### ashell — "ready to go" Hyprland bar
- **Stack:** Rust, config file
- **Install:** AUR (`ashell`)
- **Pros:** Sensible defaults, works immediately, lighter than a GTK bar, Hyprland-native.
- **Cons:** Smaller community, less flexible than Waybar/AGS, still young.

### HyprPanel (Jas-SinghFSU) — feature-rich panel
- **Stack:** TypeScript, built on AGS/Astal
- **Install:** AUR (`hyprpanel`)
- **Pros:** Looks polished out of the box; lots of menus, system controls and widgets already
  wired up; active development.
- **Cons:** Heavier than a plain bar; tied to AGS/GTK and its API churn; can be harder to
  debug when an update changes something.

### hyprpanel (pdf) — opinionated GTK4 panel
- **Stack:** Go + GTK4
- **Install:** AUR (`hyprpanel-go` / check AUR)
- **Pros:** Lightweight Go binary, clean modern look, simple to run.
- **Cons:** Opinionated — limited deep customization; confusingly shares a name with the
  TypeScript project above; smaller ecosystem.

### Ironbar
- **Stack:** Rust, config + CSS
- **Install:** AUR (`ironbar`)
- **Pros:** Very configurable, includes GUI widgets (menus, popups), actively maintained.
- **Cons:** Smaller community than Waybar; you'll be reading docs rather than copying dots.

### nwg-panel / nwg-dock-hyprland
- **Stack:** Python/GTK3 (panel), Go/GTK3 (dock)
- **Install:** repos/AUR (`nwg-panel`, `nwg-dock-hyprland`)
- **Pros:** GUI configuration app; familiar panel+dock workflow; good Hyprland support.
- **Cons:** GTK3 look feels dated next to GTK4/Qt shells; heavier runtime.

### Also worth a look
| Project | Stack | Take |
|---|---|---|
| `gBar` | C++/GTK3 | Extremely fast and lean, minimal features |
| `sysbar` | C++ | Modular bar from the sys* family; pairs with sysshell/syshud |
| `Hybrid` | Rust | Featureful bar for wlroots compositors, growing community |
| `wayle` | Rust | See all-in-one shells below |

---

## 2. Widget / shell frameworks
These are toolkits: you write code to build your bar, popups, control center, etc.

### AGS + Astal — most popular full-shell toolkit
- **Stack:** GTK4 (Astal) + JavaScript/TypeScript (GJS)
- **Install:** AUR (`ags`, `astal` libs; `ags-git` for latest)
- **Pros:** Largest library of ready-made configs/dotfiles; huge community; built-in services
  for notifications, Bluetooth, network, audio, brightness; TypeScript support makes larger
  shells manageable; v3 (GTK4) is smoother and lighter than older versions.
- **Cons:** Real learning curve (GJS + GTK widgets); GTK dependency; APIs have changed between
  major versions, so old configs need porting; more moving parts than a simple bar.

### Quickshell — Qt/QML shell toolkit
- **Stack:** C++ engine, QML config
- **Install:** AUR (`quickshell`, `quickshell-git`)
- **Pros:** Very smooth animations and rendering; QML is declarative and approachable if you
  know Qt; fast and relatively lightweight; used by Omarchy and many 2026 dotfiles; excellent
  documentation site.
- **Cons:** QML is its own ecosystem; Qt dependency; community smaller than AGS but growing
  fast; debugging QML can be awkward.

### EWW (Elkowar's Wacky Widgets)
- **Stack:** Rust + GTK3, config in "Yuck" (Lisp-like DSL)
- **Install:** AUR (`eww-wayland`)
- **Pros:** Compositor-agnostic; single binary; very flexible once you learn Yuck; great for
  bespoke floating widgets (bars, sidebars, sysinfo panels).
- **Cons:** Yuck is niche — few people can help; GTK3; you wire up most logic yourself with
  shell scripts; less "desktop shell" and more "widget engine".

### Ignis
- **Stack:** Python + GTK4
- **Install:** AUR (`ignis`)
- **Pros:** Python is easy to pick up; GTK4; clean API for bars and widgets.
- **Cons:** Newer and smaller community; fewer example configs to copy.

### Fabric
- **Stack:** Python + GTK
- **Install:** AUR (`fabric`)
- **Pros:** Python-based widget framework for Wayland *and* X11; approachable for Python devs.
- **Cons:** Very new; limited docs/examples; you'll be figuring things out yourself.

### sysshell
- **Stack:** C++
- **Install:** AUR / build from source
- **Pros:** Generic Wayland shell framework; pairs with `sysbar`, `syshud`, `wayle` family.
- **Cons:** Niche, small community, DIY.

---

## 3. All-in-one shells (bar + notifications + OSD + more)

### Wayle
- **Stack:** Rust
- **Install:** AUR / build from source
- **Pros:** Bar, notifications, OSD, wallpaper and device controls in one daemon; lightweight;
  coherent look without mixing five tools.
- **Cons:** New project; limited customization and community; may not cover exotic setups.

### Hyprshell
- **Stack:** Rust + GTK4
- **Install:** AUR (`hyprshell`) — see github.com/H3rmt/hyprshell
- **Pros:** Excellent GTK4 window switcher / app launcher with live previews; CSS theming,
  config hot-reload, useful CLI tools.
- **Cons:** It is a **launcher/switcher**, not a full bar/shell; still needs Waybar or similar.

### HyprPanel / AGS / Quickshell builds
Many "shells" people show off are actually a custom AGS or Quickshell config (e.g. end_4's
dotfiles). They can replace the bar, add a control center, overview, lock screen, etc.

---

## 4. Preconfigured setups & "instant desktop"

> ⚠️ The Hyprland wiki warns that many of these installers modify your system deeply, and
> their uninstall scripts may not fully clean up. Snapshot your config / be ready to reinstall.

### HyDE (Hyprland Desktop Environment)
- **What:** Installer script + dotfiles + theme engine for an existing Arch (or other) install.
- **Get:** `git clone https://github.com/HyDE-Project/HyDE && cd HyDE/Scripts && ./install.sh`
- **Pros:** Turns your current Arch into a fully themed desktop; many themes; Waybar-based so
  familiar; granular install flags (`-i`, `-m`, `-n`, `-t` dry run, etc.).
- **Cons:** Changes a lot of files; can be tricky to remove cleanly; you inherit someone else's
  keybinds and structure until you learn it.

### Omarchy
- **What:** Full Arch-based distro with Hyprland + Quickshell, by DHH.
- **Get:** ISO from omarchy.org.
- **Pros:** Zero setup; coherent, polished theming; keyboard-first workflow; Quickshell shell
  with bar, menus, launcher; frequent releases.
- **Cons:** It's a whole distro, not a package for your current Arch; strongly opinionated
  defaults; diverging from upstream means maintaining your own fork.

### end_4 dotfiles
- **What:** Highly polished Quickshell-based dotfiles (moved off Waybar entirely).
- **Pros:** Stunning mobile/OS-like control center and animations; great as a learning reference.
- **Cons:** Complex; updating means tracking upstream; expect to learn Quickshell to tweak it.

### ML4W Hyprland (My Linux For Work)
- **What:** Installer + dotfiles bundle with documentation.
- **Pros:** Stable, well-documented, good for newcomers who want a complete setup.
- **Cons:** Opinionated; some parts are scripted and hard to unpick.

### Others you'll see mentioned
Dank Linux, fufexan's dots, coffebar, and many YouTube-driven dotfiles repos. Same trade-off:
fast beautiful result, but a maintenance and cleanup burden. Treat them as starting points,
not permanent foundations, unless you're willing to own the config.

---

## 5. Companion pieces (not shells, but you'll want them)

| Need | Popular choices | Notes |
|---|---|---|
| Launcher | `rofi-wayland`, `wofi`, `fuzzel`, `bemenu`, Walker, Vicinae, Hyprlauncher | `rofi-wayland` is the safe default; Walker/Vicinae run as services for instant startup |
| Notifications | `swaync` (notification center), `mako`, `dunst`, `fnott` | SwayNC gives GNOME-style history panel |
| Lock / idle | `hyprlock`, `hypridle` | Official Hyprland tools; highly recommended |
| Wallpaper | `hyprpaper`, `waypaper` | hyprpaper = daemon, waypaper = GUI picker |
| Power menu | `wlogout`, or a shell's own menu | Layer-shell overlay for lock/logout/reboot |
| OSD | `swayosd`, `avizo`, `wob`, `syshud` | Volume/brightness feedback |

---

## Suggested upgrade path from a basic setup

1. `sudo pacman -S waybar rofi-wayland swaync hyprlock hypridle hyprpaper wlogout`
2. Copy `/etc/xdg/waybar/config*` and `style.css` to `~/.config/waybar/`, swap
   `sway/workspaces` → `hyprland/workspaces` and `sway/mode` → `hyprland/submap`.
3. Bind Super+R → rofi, Super+L → hyprlock, Super+Shift+E → wlogout in `hyprland.conf`.
4. Once comfortable, try creating a small popup in EWW or a QML snippet in Quickshell.
5. If you want the full deal, build an AGS/Quickshell shell gradually, or install HyDE.

## References
- https://wiki.hypr.land/useful-utilities/status-bars/
- https://github.com/hyprland-community/awesome-hyprland
- https://wiki.hypr.land/getting-started/preconfigured-setups/
