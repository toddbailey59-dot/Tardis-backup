import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: store

    property bool loading: true
    property string accent: "blue"
    property int barHeight: 34
    property int cornerRadius: 12
    property real barOpacity: 0.88
    property int launcherColumns: 4
    property int popupTimeout: 5000
    property bool clock24h: true
    property bool clockSeconds: false
    property bool showWindowTitle: true
    property bool showWorkspaceNumbers: true
    property bool dnd: false
    property bool animate: false
    property bool showSysStats: true
    property bool showWeather: true
    property real weatherLat: 42.3314
    property real weatherLon: -83.0458
    property string weatherUnit: "F"
    property int weatherRefresh: 15
    property bool wallpaperSlideshow: true
    property int wallpaperSlideshowMinutes: 5

    readonly property color blue: "#22558f"
    readonly property color gold: "#e5b64c"
    readonly property color green: "#c3e88d"
    readonly property color red: "#f07178"
    readonly property color cream: "#efe5c6"

    readonly property color accentColor: {
        if (accent === "gold") return gold
        if (accent === "green") return green
        if (accent === "red") return red
        return blue
    }
    readonly property color bg: "#0a1424"
    readonly property color panel: "#0d1b31"
    readonly property color panelSoft: "#123a6b"
    readonly property color border: "#22558f"
    readonly property color text: "#efe5c6"
    readonly property color muted: "#9aa8c0"

    property FileView fileView: FileView {
        id: settingsFile
        path: Quickshell.shellPath("settings.json")
        atomicWrites: true

        onLoaded: {
            try {
                const o = JSON.parse(settingsFile.text())
                if (o.accent !== undefined) store.accent = o.accent
                if (o.barHeight !== undefined) store.barHeight = o.barHeight
                if (o.cornerRadius !== undefined) store.cornerRadius = o.cornerRadius
                if (o.barOpacity !== undefined) store.barOpacity = o.barOpacity
                if (o.launcherColumns !== undefined) store.launcherColumns = o.launcherColumns
                if (o.popupTimeout !== undefined) store.popupTimeout = o.popupTimeout
                if (o.clock24h !== undefined) store.clock24h = o.clock24h
                if (o.clockSeconds !== undefined) store.clockSeconds = o.clockSeconds
                if (o.showWindowTitle !== undefined) store.showWindowTitle = o.showWindowTitle
                if (o.showWorkspaceNumbers !== undefined) store.showWorkspaceNumbers = o.showWorkspaceNumbers
                if (o.dnd !== undefined) store.dnd = o.dnd
                if (o.animate !== undefined) store.animate = o.animate
                if (o.showSysStats !== undefined) store.showSysStats = o.showSysStats
                if (o.showWeather !== undefined) store.showWeather = o.showWeather
                if (o.weatherLat !== undefined) store.weatherLat = o.weatherLat
                if (o.weatherLon !== undefined) store.weatherLon = o.weatherLon
                if (o.weatherUnit !== undefined) store.weatherUnit = o.weatherUnit
                if (o.weatherRefresh !== undefined) store.weatherRefresh = o.weatherRefresh
                if (o.wallpaperSlideshow !== undefined) store.wallpaperSlideshow = o.wallpaperSlideshow
                if (o.wallpaperSlideshowMinutes !== undefined) store.wallpaperSlideshowMinutes = o.wallpaperSlideshowMinutes
            } catch (e) {
                // keep defaults on malformed json
            }
            store.loading = false
        }

        onLoadFailed: store.loading = false
    }

    function snapshot() {
        return {
            accent: accent,
            barHeight: barHeight,
            cornerRadius: cornerRadius,
            barOpacity: barOpacity,
            launcherColumns: launcherColumns,
            popupTimeout: popupTimeout,
            clock24h: clock24h,
            clockSeconds: clockSeconds,
            showWindowTitle: showWindowTitle,
            showWorkspaceNumbers: showWorkspaceNumbers,
            dnd: dnd,
            animate: animate,
            showSysStats: showSysStats,
            showWeather: showWeather,
            weatherLat: weatherLat,
            weatherLon: weatherLon,
            weatherUnit: weatherUnit,
            weatherRefresh: weatherRefresh,
            wallpaperSlideshow: wallpaperSlideshow,
            wallpaperSlideshowMinutes: wallpaperSlideshowMinutes
        }
    }

    function save() {
        if (loading) return
        settingsFile.setText(JSON.stringify(snapshot(), null, 2))
    }

    function get(key) {
        const o = snapshot()
        return o[key] !== undefined ? String(o[key]) : ""
    }

    function list() {
        return JSON.stringify(snapshot())
    }

    function set(key, value) {
        const str = String(value)
        let n
        switch (key) {
        case "accent":
            if (["blue", "gold", "green", "red"].indexOf(str) >= 0) accent = str
            break
        case "barHeight":
            barHeight = Math.max(24, Math.min(56, parseInt(str, 10) || barHeight))
            break
        case "cornerRadius":
            cornerRadius = Math.max(0, Math.min(24, parseInt(str, 10) || 0))
            break
        case "barOpacity":
            n = parseFloat(str)
            if (!isNaN(n)) barOpacity = Math.max(0.4, Math.min(1, n))
            break
        case "launcherColumns":
            launcherColumns = Math.max(2, Math.min(6, parseInt(str, 10) || launcherColumns))
            break
        case "popupTimeout":
            popupTimeout = Math.max(1500, Math.min(15000, parseInt(str, 10) || popupTimeout))
            break
        case "clock24h":
            clock24h = str === "true" || str === "1"
            break
        case "clockSeconds":
            clockSeconds = str === "true" || str === "1"
            break
        case "showWindowTitle":
            showWindowTitle = str === "true" || str === "1"
            break
        case "showWorkspaceNumbers":
            showWorkspaceNumbers = str === "true" || str === "1"
            break
        case "dnd":
            dnd = str === "true" || str === "1"
            break
        case "animate":
            animate = str === "true" || str === "1"
            break
        case "showSysStats":
            showSysStats = str === "true" || str === "1"
            break
        case "showWeather":
            showWeather = str === "true" || str === "1"
            break
        case "weatherLat":
            n = parseFloat(str)
            if (!isNaN(n)) weatherLat = Math.max(-90, Math.min(90, n))
            break
        case "weatherLon":
            n = parseFloat(str)
            if (!isNaN(n)) weatherLon = Math.max(-180, Math.min(180, n))
            break
        case "weatherUnit":
            if (str === "F" || str === "C") weatherUnit = str
            break
        case "weatherRefresh":
            weatherRefresh = Math.max(1, Math.min(60, parseInt(str, 10) || weatherRefresh))
            break
        case "wallpaperSlideshow":
            wallpaperSlideshow = str === "true" || str === "1"
            break
        case "wallpaperSlideshowMinutes":
            wallpaperSlideshowMinutes = Math.max(1, Math.min(60, parseInt(str, 10) || wallpaperSlideshowMinutes))
            break
        default:
            return "UNKNOWN_KEY"
        }
        save()
        return get(key)
    }

    function reset() {
        accent = "blue"
        barHeight = 34
        cornerRadius = 12
        barOpacity = 0.88
        launcherColumns = 4
        popupTimeout = 5000
        clock24h = true
        clockSeconds = false
        showWindowTitle = true
        showWorkspaceNumbers = true
        dnd = false
        animate = false
        showSysStats = true
        showWeather = true
        weatherLat = 42.3314
        weatherLon = -83.0458
        weatherUnit = "F"
        weatherRefresh = 15
        wallpaperSlideshow = true
        wallpaperSlideshowMinutes = 5
        save()
    }

    function cycleAccent() {
        const order = ["blue", "gold", "green", "red"]
        const i = order.indexOf(accent)
        accent = order[(i + 1) % order.length]
        save()
    }
}
