import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    property var shell

    property IpcHandler handler: IpcHandler {
        target: "tardis"

        function toggleLauncher(): void { shell.toggleLauncher() }
        function togglePower(): void { shell.togglePower() }
        function toggleNotifications(): void { shell.toggleNotifications() }
        function toggleQuick(): void { shell.toggleQuick() }
        function toggleClipboard(): void { shell.toggleClipboard() }
        function toggleChat(): void { shell.toggleChat() }
        function toggleSettings(): void { shell.toggleSettings() }
        function toggleHelp(): void { shell.toggleHelp() }
        function toggleWallpaperGallery(): void { shell.toggleGallery() }
        function overviewCycle(): void { shell.overviewCycle(1) }
        function overviewCycleBack(): void { shell.overviewCycle(-1) }
        function closeOverlays(): void { shell.closeOverlays() }
        function reloadShell(): void { Quickshell.reload(false) }

        function settingsList(): string { return shell.settings.list() }
        function settingsGet(key: string): string { return shell.settings.get(key) }
        function settingsSet(key: string, value: string): string { return shell.settings.set(key, value) }
        function settingsReset(): void { shell.settings.reset() }
        function statsInfo(): string { return shell.stats.sysText + " | " + shell.stats.weatherText }
        function statsRefresh(): void { shell.stats.refreshAll() }
        function wallpaperNext(): void { shell.nextWallpaper() }
        function wallpaperInfo(): string {
            return (shell.settings.wallpaperSlideshow ? "on" : "off") +
                   " / " + shell.settings.wallpaperSlideshowMinutes + " min"
        }
    }
}
