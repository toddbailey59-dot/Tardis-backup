import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: stats

    property var settings

    property real loadAvg: 0
    property int cpuTemp: 0
    property int memPct: 0

    property real weatherTemp: 0
    property int weatherHumidity: 0
    property int weatherCode: -1
    property bool weatherValid: false

    readonly property string weatherIcon: {
        switch (weatherCode) {
        case 0: return "☀"
        case 1:
        case 2: return "⛅"
        case 3: return "☁"
        case 45:
        case 48: return "≋"
        case 51:
        case 53:
        case 55:
        case 56:
        case 57:
        case 61:
        case 63:
        case 65:
        case 66:
        case 67:
        case 80:
        case 81:
        case 82: return "☂"
        case 71:
        case 73:
        case 75:
        case 77:
        case 85:
        case 86: return "❄"
        case 95:
        case 96:
        case 99: return "⚡"
        default: return "◌"
        }
    }

    readonly property string weatherText: weatherValid
        ? weatherIcon + " " + Math.round(weatherTemp) + "°" + (settings ? settings.weatherUnit : "F")
        : "◌ --"

    readonly property string weatherDesc: {
        switch (weatherCode) {
        case 0: return "Clear sky"
        case 1: return "Mainly clear"
        case 2: return "Partly cloudy"
        case 3: return "Overcast"
        case 45:
        case 48: return "Fog"
        case 51:
        case 53:
        case 55: return "Drizzle"
        case 56:
        case 57: return "Freezing drizzle"
        case 61:
        case 63:
        case 65: return "Rain"
        case 66:
        case 67: return "Freezing rain"
        case 71:
        case 73:
        case 75:
        case 77: return "Snow"
        case 80:
        case 81:
        case 82: return "Rain showers"
        case 85:
        case 86: return "Snow showers"
        case 95: return "Thunderstorm"
        case 96:
        case 99: return "Thunderstorm with hail"
        default: return "Weather unavailable"
        }
    }

    readonly property string sysText:
        "LD " + loadAvg.toFixed(2) + "  " + cpuTemp + "°  MEM " + memPct + "%"

    property Timer sysTimer: Timer {
        interval: 5000
        repeat: true
        running: true
        onTriggered: stats.refreshSys()
        Component.onCompleted: stats.refreshSys()
    }

    property Timer weatherTimer: Timer {
        interval: Math.max(1, stats.settings ? stats.settings.weatherRefresh : 15) * 60000
        repeat: true
        running: true
        onTriggered: stats.refreshWeather()
    }

    property Timer startupTimer: Timer {
        interval: 1200
        repeat: false
        running: true
        onTriggered: stats.refreshAll()
    }

    property Connections settingsConnections: Connections {
        target: stats.settings
        function onWeatherLatChanged() { stats.refreshWeather() }
        function onWeatherLonChanged() { stats.refreshWeather() }
        function onWeatherUnitChanged() { stats.refreshWeather() }
        function onWeatherRefreshChanged() { stats.refreshWeather() }
        function onShowWeatherChanged() {
            if (stats.settings.showWeather) stats.refreshWeather()
        }
    }

    property Process sysProcess: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const o = JSON.parse(this.text)
                    stats.loadAvg = parseFloat(o.load) || 0
                    stats.cpuTemp = parseInt(o.temp, 10) || 0
                    stats.memPct = parseInt(o.mem, 10) || 0
                } catch (e) {
                    // keep last known values on bad output
                }
            }
        }
    }

    property Process weatherProcess: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const o = JSON.parse(this.text)
                    const current = o.current || {}
                    const temp = parseFloat(current.temperature_2m)
                    const humidity = parseInt(current.relative_humidity_2m, 10)
                    const code = parseInt(current.weather_code, 10)
                    stats.weatherTemp = isNaN(temp) ? 0 : temp
                    stats.weatherHumidity = isNaN(humidity) ? 0 : humidity
                    stats.weatherCode = isNaN(code) ? -1 : code
                    stats.weatherValid = true
                } catch (e) {
                    stats.weatherValid = false
                }
            }
        }
    }

    function refreshSys() {
        sysProcess.exec(["sh", Quickshell.shellPath("sysstats.sh")])
    }

    function refreshWeather() {
        if (!settings) return
        const unit = settings.weatherUnit === "C" ? "celsius" : "fahrenheit"
        weatherProcess.exec([
            "sh", Quickshell.shellPath("weather.sh"),
            String(settings.weatherLat), String(settings.weatherLon), unit
        ])
    }

    function refreshAll() {
        refreshSys()
        refreshWeather()
    }

    onSettingsChanged: refreshAll()
}
