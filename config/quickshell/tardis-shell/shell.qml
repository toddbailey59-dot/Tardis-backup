//@ pragma StateDir $BASE/tardis-shell
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Notifications

ShellRoot {
    id: root

    property var settings: settingsStore
    property var audio: audioService
    property var stats: statsService
    property var currentScreen: {
        const focused = Hyprland.focusedMonitor
        const screens = Quickshell.screens
        for (const screen of screens) {
            const monitor = Hyprland.monitorFor(screen)
            if (monitor && focused && monitor.id === focused.id) return screen
        }
        return screens.length > 0 ? screens[0] : null
    }

    readonly property int notificationCount: notifServer.trackedNotifications.values.length
    property date now: systemClock.date

    property bool launcherOpen: false
    property bool powerOpen: false
    property bool notificationsOpen: false
    property bool quickOpen: false
    property bool clipboardOpen: false
    property bool chatOpen: false
    property bool settingsOpen: false
    property bool overviewOpen: false
    property bool helpOpen: false
    property int overviewIndex: 0
    property bool volumeNotifyReady: false

    property Connections audioNotifier: Connections {
        target: audioService
        function onVolumeChanged() {
            if (root.volumeNotifyReady) volumeNotifyTimer.restart()
        }
        function onMutedChanged() {
            if (root.volumeNotifyReady) volumeNotifyTimer.restart()
        }
    }

    property Timer volumeReadyTimer: Timer {
        interval: 2000
        repeat: false
        running: true
        onTriggered: root.volumeNotifyReady = true
    }

    property Timer volumeNotifyTimer: Timer {
        interval: 300
        repeat: false
        onTriggered: root.sendVolumeNotification()
    }

    property Timer wallpaperTimer: Timer {
        repeat: true
        running: root.settings && root.settings.wallpaperSlideshow
        interval: Math.max(1, root.settings ? root.settings.wallpaperSlideshowMinutes : 5) * 60000
        onTriggered: root.nextWallpaper()
    }

    SystemClock {
        id: systemClock
        precision: SystemClock.Seconds
    }

    Settings {
        id: settingsStore
    }

    property Connections wallpaperSettingsWatcher: Connections {
        target: settingsStore
        function onWallpaperSlideshowChanged() { root.restartWallpaperTimer() }
        function onWallpaperSlideshowMinutesChanged() { root.restartWallpaperTimer() }
    }

    Stats {
        id: statsService
        settings: settingsStore
    }

    Audio {
        id: audioService
    }

    ClipboardCopy {
        id: clipboardCopy
    }

    NotificationServer {
        id: notifServer
        keepOnReload: false
        actionsSupported: true
        bodyMarkupSupported: true
        bodyImagesSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notif => {
            if (!notif.transient) notif.tracked = true
            notificationsUI.addPopup(notif)
        }
    }

    Notifications {
        id: notificationsUI
        shell: root
        server: notifServer
    }

    IPC {
        shell: root
    }

    Bar {
        shell: root
    }

    Launcher {
        shell: root
    }

    QuickSettings {
        shell: root
    }

    PowerMenu {
        shell: root
    }

    Clipboard {
        shell: root
    }

    Chat {
        shell: root
    }

    Overview {
        shell: root
    }

    SettingsPanel {
        shell: root
    }

    HelpPanel {
        shell: root
    }

    function showOnly(name) {
        launcherOpen = name === "launcher"
        powerOpen = name === "power"
        notificationsOpen = name === "notifications"
        quickOpen = name === "quick"
        clipboardOpen = name === "clipboard"
        chatOpen = name === "chat"
        settingsOpen = name === "settings"
        overviewOpen = name === "overview"
        helpOpen = name === "help"
    }

    function closeOverlays() { showOnly("") }
    function toggleLauncher() { showOnly(launcherOpen ? "" : "launcher") }
    function togglePower() { showOnly(powerOpen ? "" : "power") }
    function toggleNotifications() { showOnly(notificationsOpen ? "" : "notifications") }
    function toggleQuick() { showOnly(quickOpen ? "" : "quick") }
    function toggleClipboard() { showOnly(clipboardOpen ? "" : "clipboard") }
    function toggleChat() { showOnly(chatOpen ? "" : "chat") }
    function toggleSettings() { showOnly(settingsOpen ? "" : "settings") }
    function toggleHelp() { showOnly(helpOpen ? "" : "help") }
    function closeLauncher() { launcherOpen = false }
    function closePower() { powerOpen = false }
    function closeNotifications() { notificationsOpen = false }
    function closeQuick() { quickOpen = false }
    function closeClipboard() { clipboardOpen = false }
    function closeChat() { chatOpen = false }
    function closeSettings() { settingsOpen = false }
    function closeOverview() { overviewOpen = false }
    function closeHelp() { helpOpen = false }
    function openSettings() { showOnly("settings") }
    function openNotifications() { showOnly("notifications") }

    function overviewCycle(delta) {
        const list = Hyprland.workspaces.values.filter(ws => ws.id > 0)
        if (list.length === 0) return
        if (!overviewOpen) {
            showOnly("overview")
            const activeId = Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1
            let index = 0
            for (let i = 0; i < list.length; i++) {
                if (list[i].id === activeId) { index = i; break }
            }
            overviewIndex = index
        }
        overviewIndex = (overviewIndex + delta + list.length) % list.length
        list[overviewIndex].activate()
    }

    function run(args) {
        Quickshell.execDetached({ command: args })
    }

    function nextWallpaper() {
        run([Quickshell.env("HOME") + "/bin/wp-next"])
    }

    function restartWallpaperTimer() {
        if (wallpaperTimer.running) wallpaperTimer.restart()
    }

    function reload() {
        Quickshell.reload(false)
    }

    function copyToClipboard(value) {
        clipboardCopy.copy(value)
    }

    function sendVolumeNotification() {
        if (!settings || settings.dnd || !audioService.available) return
        const muted = audioService.muted
        const percent = Math.round(audioService.volume * 100) + "%"
        const title = muted ? "🔇 MUTE" : "🔊 " + percent
        const icon = muted ? "audio-volume-muted" : "audio-volume-high"
        run(["notify-send", "-a", "TARDIS Volume", "-i", icon, "-t", "1800", title])
    }

    function screenshotPath() {
        return Quickshell.env("HOME") + "/Pictures/tardis-" +
               Qt.formatDateTime(new Date(), "yyyy-MM-dd_HHmmss") + ".png"
    }

    function screenshotFull() {
        run(["grim", screenshotPath()])
    }

    function screenshotRegion() {
        const path = screenshotPath()
        run(["sh", "-c", "grim -g \"$(slurp)\" " + path])
    }
}
