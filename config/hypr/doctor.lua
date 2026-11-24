-- doctor.lua -- 4th Doctor / TARDIS theme for Hyprland
require("monitors")
require("workspaces")

-- ---------- palette ----------
local blue   = "rgba(22558fff)"
local gold   = "rgba(e5b64cff)"
local cream  = "rgba(efe5c6ff)"

-- ---------- look ----------
hl.config({
    ecosystem = {
        no_donation_nag = true,
    }
})

hl.config({
    general = {
        gaps_in      = 2,
        gaps_out     = 8,
        border_size  = 3,
        col = {
            active_border   = { colors = { blue, gold }, angle = 45 },
            inactive_border = "rgba(123a6b33)",
        },
        layout       = "dwindle",
    },
    decoration = {
        rounding         = 12,
        active_opacity   = 0.98,
        inactive_opacity = 0.92,
        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 3,
            color        = "0xff0a0a1a",
        },
        blur = {
            enabled  = false,
            size     = 6,
            passes   = 2,
            vibrancy = 0.2,
            xray     = false,
        },
    },
    animations = { enabled = false },
})

hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})

-- ---------- autostart ----------
hl.on("hyprland.start", function ()
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
    hl.exec_cmd("sh -c 'pkill -x hyprpaper 2>/dev/null || true; sleep 0.5; /home/doctor/.local/bin/hyprpaper'")
    hl.exec_cmd("sh -c 'sleep 1 && ~/bin/wp-apply'")
    -- TARDIS shell replaces waybar + dunst.
    hl.exec_cmd("pkill -x dunst")
    hl.exec_cmd("quickshell -p /home/doctor/.config/quickshell/tardis-shell")
    -- Start reminders explicitly rather than relying on session target ordering.
    hl.exec_cmd("sh -c 'sleep 2 && systemctl --user start evolution-alarm-notify.service'")
    hl.exec_cmd("sh -c 'sleep 4 && kitty --class welcome -e bash ~/bin/welcome'")
end)

local SUPER = "SUPER"

-- wallpaper switcher
hl.bind(SUPER .. " + W", hl.dsp.exec_cmd("sh ~/bin/wp-next"))
hl.bind(SUPER .. " + SHIFT + W", hl.dsp.exec_cmd("sh ~/bin/wp-select"))

-- extra terminals / apps
hl.bind(SUPER .. " + T", hl.dsp.exec_cmd("alacritty"))
hl.bind(SUPER .. " + A", hl.dsp.exec_cmd("qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis toggleLauncher"))
hl.bind(SUPER .. " + F", hl.dsp.exec_cmd("firefox"))
hl.bind(SUPER .. " + B", hl.dsp.exec_cmd("librewolf "))
hl.bind(SUPER .. " + G", hl.dsp.exec_cmd("kitty --class ai -e opencode"))
hl.bind(SUPER .. " + ALT + A", hl.dsp.exec_cmd("kitty --class ai-chat -e /home/doctor/.local/bin/llama-chat"))
hl.bind(SUPER .. " + SHIFT + E", hl.dsp.exec_cmd("/home/doctor/.local/bin/code /home/doctor/Code/tardis.code-workspace"))
hl.bind(SUPER .. " + O", hl.dsp.exec_cmd("xdg-open http://127.0.0.1:3000"))
hl.bind(SUPER .. " + C", hl.dsp.exec_cmd("xdg-open http://127.0.0.1:3010"))
hl.bind(SUPER .. " + R", hl.dsp.exec_cmd("/home/doctor/.local/bin/morning-brief run --speak"))

-- system / theme
hl.bind(SUPER .. " + H", hl.dsp.exec_cmd("qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis toggleHelp"))
hl.bind(SUPER .. " + K", hl.dsp.exec_cmd("qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis togglePower"))
hl.bind(SUPER .. " + L", hl.dsp.exec_cmd("hyprlock"))

-- screenshots
hl.bind("Print",         hl.dsp.exec_cmd("grim ~/Pictures/$(date +%Y-%m-%d_%H%M%S).png"), { locked = true })
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" ~/Pictures/$(date +%Y-%m-%d_%H%M%S).png"), { locked = true })
hl.bind(SUPER .. " + Print", hl.dsp.exec_cmd("sh ~/bin/shot-window"), { locked = true })

-- color picker: pick any pixel, hex goes to clipboard (hyprpicker)
hl.bind(SUPER .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))

-- quickshell panels
hl.bind(SUPER .. " + N", hl.dsp.exec_cmd("qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis toggleNotifications"))
hl.bind(SUPER .. " + D", hl.dsp.exec_cmd("qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis toggleQuick"))
hl.bind(SUPER .. " + SHIFT + V", hl.dsp.exec_cmd("qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis toggleClipboard"))
hl.bind(SUPER .. " + I", hl.dsp.exec_cmd("qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis toggleChat"))

-- workspace overview is built into the TARDIS shell
hl.bind(SUPER .. " + TAB", hl.dsp.exec_cmd("qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis overviewCycle"))
hl.bind(SUPER .. " + SHIFT + TAB", hl.dsp.exec_cmd("qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis overviewCycleBack"))

-- close window as SUPER+SHIFT+Q
hl.bind(SUPER .. " + SHIFT + Q", hl.dsp.window.close())

-- ---------- window rules ----------
hl.window_rule({
    name = "gnome-calendar-float",
    -- Hyprland matches these with regex, not Lua patterns: use \. not %.
    match = { class = "^org\\.gnome\\.Calendar$" },
    float = true,
    center = true,
    pin = true,
    size = { 1100, 800 },
})
hl.window_rule({
    name  = "ai-float",
    match = { class = "^ai$" },
    float = true,
    size  = { 1280, 800 },
})
hl.window_rule({
    name  = "welcome-float",
    match = { class = "^welcome$" },
    float = true,
    size  = { 1100, 660 },
    move  = "center center",
})
hl.window_rule({
    name  = "forecast-float",
    match = { class = "^forecast$" },
    float = true,
    pin   = true,
    size  = { 1100, 800 },
    center = true,
})
hl.window_rule({
    name  = "spotify-float",
    match = { class = "^spotify$" },
})

-- ---------- webapp monitors (Firefox) ----------
-- Firefox maps the window as "Mozilla Firefox" and only sets the real page
-- title afterwards, so static title window rules never match. React to the
-- title event and float/move/resize the window once the dashboard title lands.
local function place_webapp(w, ws)
    hl.dispatch(hl.dsp.window.float({ action = "enable", window = w }))
    hl.dispatch(hl.dsp.window.resize({ x = 1400, y = 900, window = w }))
    hl.dispatch(hl.dsp.window.move({ workspace = ws, window = w }))
    hl.dispatch(hl.dsp.window.center({ window = w }))
end

hl.on("window.title", function(w)
    if w == nil then return end
    local title = w.title or ""
    if title:match("[Oo]utage recovery") then
        place_webapp(w, 2)
    elseif title:match("[Hh]ost check") then
        place_webapp(w, 3)
    end
end)

-- Launch monitors
hl.bind(SUPER .. " + SHIFT + N", hl.dsp.exec_cmd("~/bin/launch-netcheck"))
hl.bind(SUPER .. " + SHIFT + H", hl.dsp.exec_cmd("~/bin/launch-hostcheck"))
hl.bind(SUPER .. " + M",       hl.dsp.exec_cmd("~/bin/launch-monitors"))
