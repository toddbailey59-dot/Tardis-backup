-- Workspace placement for the active Hyprland (Lua) config, hand-maintained.
-- Workspaces are pinned per-monitor: DP-3 hosts 1-5, HDMI-A-1 hosts 6-10.
-- persistent = true makes each workspace exist from startup on its pinned
-- monitor instead of being created ad hoc on whichever monitor is focused.

hl.workspace_rule({
    workspace = "1",
    monitor = "DP-3",
    default = true,
    persistent = true
})
hl.workspace_rule({
    workspace = "2",
    monitor = "DP-3",
    persistent = true
})
hl.workspace_rule({
    workspace = "3",
    monitor = "DP-3",
    persistent = true
})
hl.workspace_rule({
    workspace = "4",
    monitor = "DP-3",
    persistent = true
})
hl.workspace_rule({
    workspace = "5",
    monitor = "DP-3",
    persistent = true
})
hl.workspace_rule({
    workspace = "6",
    monitor = "HDMI-A-1",
    default = true,
    persistent = true
})
hl.workspace_rule({
    workspace = "7",
    monitor = "HDMI-A-1",
    persistent = true
})
hl.workspace_rule({
    workspace = "8",
    monitor = "HDMI-A-1",
    persistent = true
})
hl.workspace_rule({
    workspace = "9",
    monitor = "HDMI-A-1",
    persistent = true
})
hl.workspace_rule({
    workspace = "10",
    monitor = "HDMI-A-1",
    persistent = true
})
