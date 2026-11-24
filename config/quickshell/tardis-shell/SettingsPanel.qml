import QtQuick

Modal {
    id: settingsPanel
    title: "TARDIS SHELL SETTINGS"
    cardWidth: 620
    cardHeight: 620
    open: shell ? shell.settingsOpen : false
    onCloseRequested: shell.closeSettings()

    property var shell
    property var settings: shell ? shell.settings : null

    Flickable {
        anchors.fill: parent
        contentHeight: contentColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: contentColumn
            width: parent.width
            spacing: 8

            Text {
                width: parent.width
                text: "All changes save instantly to settings.json."
                color: settings ? settings.muted : "#9aa8c0"
                font.family: "JetBrains Mono"
                font.pixelSize: 10
            }

            Rectangle {
                width: parent.width
                height: 48
                radius: settings ? Math.max(6, settings.cornerRadius - 4) : 8
                color: settings ? settings.bg : "#0a1424"
                border.width: 1
                border.color: settings ? settings.border : "#22558f"

                Row {
                    anchors {
                        fill: parent
                        margins: 8
                    }
                    spacing: 8

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "ACCENT"
                        color: settings ? settings.text : "#efe5c6"
                        font.family: "JetBrains Mono"
                        font.pixelSize: 11
                    }

                    Item { width: 10; height: 1 }

                    Repeater {
                        model: ["blue", "gold", "green", "red"]

                        delegate: Rectangle {
                            width: 32
                            height: 28
                            radius: 7
                            color: {
                                if (modelData === "blue") return "#22558f"
                                if (modelData === "gold") return "#e5b64c"
                                if (modelData === "green") return "#c3e88d"
                                return "#f07178"
                            }
                            border.width: settings && settings.accent === modelData ? 3 : 1
                            border.color: settings ? settings.cream : "#efe5c6"

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    settings.accent = modelData
                                    settings.save()
                                }
                            }
                        }
                    }
                }
            }

            StepperRow {
                width: parent.width
                label: "Bar height"
                value: settings ? settings.barHeight : 34
                minimum: 24
                maximum: 56
                step: 2
                settings: settingsPanel.settings
                onChanged: newValue => { settings.barHeight = newValue; settings.save() }
            }

            StepperRow {
                width: parent.width
                label: "Corner radius"
                value: settings ? settings.cornerRadius : 12
                minimum: 0
                maximum: 24
                step: 2
                settings: settingsPanel.settings
                onChanged: newValue => { settings.cornerRadius = newValue; settings.save() }
            }

            StepperRow {
                width: parent.width
                label: "Bar opacity (%)"
                value: settings ? Math.round(settings.barOpacity * 100) : 88
                minimum: 40
                maximum: 100
                step: 4
                settings: settingsPanel.settings
                onChanged: newValue => { settings.barOpacity = newValue / 100; settings.save() }
            }

            StepperRow {
                width: parent.width
                label: "Launcher columns"
                value: settings ? settings.launcherColumns : 4
                minimum: 2
                maximum: 6
                step: 1
                settings: settingsPanel.settings
                onChanged: newValue => { settings.launcherColumns = newValue; settings.save() }
            }

            StepperRow {
                width: parent.width
                label: "Popup timeout (ms)"
                value: settings ? settings.popupTimeout : 5000
                minimum: 1500
                maximum: 15000
                step: 500
                settings: settingsPanel.settings
                onChanged: newValue => { settings.popupTimeout = newValue; settings.save() }
            }

            ToggleRow {
                width: parent.width
                label: "24-hour clock"
                checked: settings ? settings.clock24h : true
                settings: settingsPanel.settings
                onToggled: { settings.clock24h = !settings.clock24h; settings.save() }
            }

            ToggleRow {
                width: parent.width
                label: "Show seconds"
                checked: settings ? settings.clockSeconds : false
                settings: settingsPanel.settings
                onToggled: { settings.clockSeconds = !settings.clockSeconds; settings.save() }
            }

            ToggleRow {
                width: parent.width
                label: "Show window title"
                checked: settings ? settings.showWindowTitle : true
                settings: settingsPanel.settings
                onToggled: { settings.showWindowTitle = !settings.showWindowTitle; settings.save() }
            }

            ToggleRow {
                width: parent.width
                label: "Show workspace numbers"
                checked: settings ? settings.showWorkspaceNumbers : true
                settings: settingsPanel.settings
                onToggled: { settings.showWorkspaceNumbers = !settings.showWorkspaceNumbers; settings.save() }
            }

            ToggleRow {
                width: parent.width
                label: "Do not disturb"
                checked: settings ? settings.dnd : false
                settings: settingsPanel.settings
                onToggled: { settings.dnd = !settings.dnd; settings.save() }
            }

            ToggleRow {
                width: parent.width
                label: "UI animations"
                checked: settings ? settings.animate : false
                settings: settingsPanel.settings
                onToggled: { settings.animate = !settings.animate; settings.save() }
            }

            ToggleRow {
                width: parent.width
                label: "Show weather"
                checked: settings ? settings.showWeather : true
                settings: settingsPanel.settings
                onToggled: { settings.showWeather = !settings.showWeather; settings.save() }
            }

            ToggleRow {
                width: parent.width
                label: "Weather in °F"
                checked: settings ? settings.weatherUnit === "F" : true
                settings: settingsPanel.settings
                onToggled: {
                    settings.weatherUnit = settings.weatherUnit === "F" ? "C" : "F"
                    settings.save()
                }
            }

            ToggleRow {
                width: parent.width
                label: "Show system stats"
                checked: settings ? settings.showSysStats : true
                settings: settingsPanel.settings
                onToggled: { settings.showSysStats = !settings.showSysStats; settings.save() }
            }

            StepperRow {
                width: parent.width
                label: "Weather refresh (min)"
                value: settings ? settings.weatherRefresh : 15
                minimum: 1
                maximum: 60
                step: 1
                settings: settingsPanel.settings
                onChanged: newValue => { settings.weatherRefresh = newValue; settings.save() }
            }

            ToggleRow {
                width: parent.width
                label: "Wallpaper slideshow"
                checked: settings ? settings.wallpaperSlideshow : true
                settings: settingsPanel.settings
                onToggled: { settings.wallpaperSlideshow = !settings.wallpaperSlideshow; settings.save() }
            }

            StepperRow {
                width: parent.width
                label: "Slideshow interval (min)"
                value: settings ? settings.wallpaperSlideshowMinutes : 5
                minimum: 1
                maximum: 60
                step: 1
                settings: settingsPanel.settings
                onChanged: newValue => { settings.wallpaperSlideshowMinutes = newValue; settings.save() }
            }

            Rectangle {
                width: parent.width
                implicitHeight: locText.implicitHeight + 16
                radius: settings ? Math.max(6, settings.cornerRadius - 4) : 8
                color: settings ? settings.bg : "#0a1424"
                border.width: 1
                border.color: settings ? settings.border : "#22558f"

                Text {
                    id: locText
                    anchors {
                        fill: parent
                        margins: 8
                    }
                    text: "WEATHER LOCATION\n" +
                          "Lat " + (settings ? settings.weatherLat.toFixed(4) : "42.3314") +
                          "  Lon " + (settings ? settings.weatherLon.toFixed(4) : "-83.0458") + "\n" +
                          "qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis settingsSet weatherLat 42.3314\n" +
                          "qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis settingsSet weatherLon -83.0458\n" +
                          "Then call tardis reloadShell to refresh immediately."
                    color: settings ? settings.muted : "#9aa8c0"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 10
                    wrapMode: Text.Wrap
                }
            }

            UiButton {
                width: parent.width
                label: "NEXT WALLPAPER"
                settings: settingsPanel.settings
                onClicked: shell.nextWallpaper()
            }

            UiButton {
                width: parent.width
                label: "RESET TO DEFAULTS"
                settings: settingsPanel.settings
                onClicked: settings.reset()
            }

            Rectangle {
                width: parent.width
                implicitHeight: cliText.implicitHeight + 16
                radius: settings ? Math.max(6, settings.cornerRadius - 4) : 8
                color: settings ? settings.bg : "#0a1424"
                border.width: 1
                border.color: settings ? settings.border : "#22558f"

                Text {
                    id: cliText
                    anchors {
                        fill: parent
                        margins: 8
                    }
                    text: "CLI CONFIG\n" +
                          "qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis settingsList\n" +
                          "qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis settingsGet barHeight\n" +
                          "qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis settingsSet barHeight 40\n" +
                          "qs ipc -p /home/doctor/.config/quickshell/tardis-shell call tardis settingsReset"
                    color: settings ? settings.muted : "#9aa8c0"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 10
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
