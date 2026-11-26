import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Variants {
    id: barVariants
    model: Quickshell.screens

    property var shell

    delegate: PanelWindow {
        id: bar
        property var modelData
        property var settings: shell.settings
        property var hyprMonitor: Hyprland.monitorFor(modelData)

        property string tipText: ""
        property real tipAnchorX: 0
        property bool tipShown: false

        function showTip(text, item, localX) {
            tipText = text
            tipAnchorX = item.mapToItem(tipCoords, localX, 0).x
            tipShown = true
        }

        function hideTip() {
            tipShown = false
            tipText = ""
        }

        screen: modelData

        anchors {
            top: true
            left: true
            right: true
        }
        margins {
            top: 8
            left: 8
            right: 8
        }
        implicitHeight: settings.barHeight
        color: "transparent"
        focusable: false
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: settings.barHeight + 16

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "tardis-bar"

        Rectangle {
            anchors.fill: parent
            radius: settings.cornerRadius
            color: settings.bg
            opacity: settings.barOpacity
            border.width: 1
            border.color: settings.border
        }

        // Coordinate space inside the window, used to anchor the tooltip pill.
        Item {
            id: tipCoords
            anchors.fill: parent
        }

        Row {
            anchors {
                left: parent.left
                leftMargin: 12
                verticalCenter: parent.verticalCenter
            }
            spacing: 6

            Text {
                id: logo
                text: "◈ TARDIS"
                color: settings.accentColor
                font.family: "JetBrains Mono"
                font.pixelSize: 12
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    id: logoArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: bar.showTip("TARDIS shell  ·  SUPER+H for keybinds", logoArea, mouseX)
                    onExited: bar.hideTip()
                }
            }

            Item { width: 6; height: 1 }

            Repeater {
                model: Hyprland.workspaces.values.filter(ws => hyprMonitor && ws.monitor && ws.monitor.id === hyprMonitor.id)

                delegate: Rectangle {
                    required property var modelData
                    property bool isActive: modelData.active
                    property bool isUrgent: modelData.urgent

                    width: settings.showWorkspaceNumbers ? 30 : 12
                    height: 24
                    radius: Math.max(4, settings.cornerRadius - 6)
                    color: isActive ? settings.accentColor : (isUrgent ? settings.red : "transparent")
                    border.width: isActive ? 0 : 1
                    border.color: settings.border

                    Text {
                        anchors.centerIn: parent
                        visible: settings.showWorkspaceNumbers
                        text: String(modelData.id)
                        color: isActive ? settings.bg : settings.text
                        font.family: "JetBrains Mono"
                        font.pixelSize: 11
                        font.bold: isActive
                    }

                    MouseArea {
                        id: workspaceArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: modelData.activate()
                        onEntered: {
                            const state = isActive ? "active" : (isUrgent ? "urgent" : "idle")
                            bar.showTip("Workspace " + modelData.id + "  ·  " + state + "  ·  click to switch", workspaceArea, mouseX)
                        }
                        onExited: bar.hideTip()
                    }
                }
            }
        }

        Text {
            id: windowTitle
            anchors.centerIn: parent
            visible: settings.showWindowTitle
            text: Hyprland.activeToplevel && Hyprland.activeToplevel.title
                ? Hyprland.activeToplevel.title
                : "TARDIS // READY"
            color: settings.text
            font.family: "JetBrains Mono"
            font.pixelSize: 12
            elide: Text.ElideMiddle
            maximumLineCount: 1
            width: Math.min(parent.width * 0.42, 520)
            horizontalAlignment: Text.AlignHCenter

            MouseArea {
                id: titleArea
                anchors.fill: parent
                hoverEnabled: true
                onEntered: bar.showTip("Focused window: " + (Hyprland.activeToplevel && Hyprland.activeToplevel.title ? Hyprland.activeToplevel.title : "none"), titleArea, mouseX)
                onExited: bar.hideTip()
            }
        }

        Row {
            anchors {
                right: parent.right
                rightMargin: 12
                verticalCenter: parent.verticalCenter
            }
            spacing: 10

            Text {
                id: weather
                anchors.verticalCenter: parent.verticalCenter
                visible: settings.showWeather
                text: shell.stats.weatherText
                color: settings.accentColor
                font.family: "JetBrains Mono"
                font.pixelSize: 11
                font.bold: true

                MouseArea {
                    id: weatherArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: bar.showTip(
                        shell.stats.weatherDesc + "  ·  " + Math.round(shell.stats.weatherTemp) + "°" + settings.weatherUnit +
                        "  ·  humidity " + shell.stats.weatherHumidity + "%", weatherArea, mouseX)
                    onExited: bar.hideTip()
                }
            }

            Text {
                id: sysStats
                anchors.verticalCenter: parent.verticalCenter
                visible: settings.showSysStats
                text: shell.stats.sysText
                color: settings.muted
                font.family: "JetBrains Mono"
                font.pixelSize: 10

                MouseArea {
                    id: statsArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: bar.showTip(
                        "Load " + shell.stats.loadAvg.toFixed(2) + "  ·  CPU " + shell.stats.cpuTemp + "°" +
                        "  ·  Memory " + shell.stats.memPct + "%", statsArea, mouseX)
                    onExited: bar.hideTip()
                }
            }

            Text {
                id: audioText
                anchors.verticalCenter: parent.verticalCenter
                text: audio.available
                    ? (audio.muted ? "◌ MUTE" : "◖ " + Math.round(audio.volume * 100) + "%")
                    : "◌ AUDIO"
                color: audio.muted ? settings.red : settings.muted
                font.family: "JetBrains Mono"
                font.pixelSize: 11

                MouseArea {
                    id: audioArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: bar.showTip(
                        audio.available
                            ? audio.name + "  ·  " + (audio.muted ? "muted" : Math.round(audio.volume * 100) + "% volume")
                            : "No audio output detected", audioArea, mouseX)
                    onExited: bar.hideTip()
                }
            }

            Text {
                id: notifications
                anchors.verticalCenter: parent.verticalCenter
                text: shell.notificationCount > 0 ? "● " + shell.notificationCount : "○"
                color: shell.notificationCount > 0 ? settings.accentColor : settings.muted
                font.family: "JetBrains Mono"
                font.pixelSize: 11

                MouseArea {
                    id: notifArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: shell.toggleNotifications()
                    onEntered: bar.showTip(
                        shell.notificationCount > 0
                            ? shell.notificationCount + " notification" + (shell.notificationCount === 1 ? "" : "s") + "  ·  click to open"
                            : "No notifications", notifArea, mouseX)
                    onExited: bar.hideTip()
                }
            }

            Text {
                id: clockText
                anchors.verticalCenter: parent.verticalCenter
                text: Qt.formatTime(clock.date, settings.clock24h ? "HH:mm" : "h:mm ap") +
                      (settings.clockSeconds ? ":" + Qt.formatTime(clock.date, "ss") : "") +
                      "  " + Qt.formatDate(clock.date, "ddd d MMM")
                color: settings.cream
                font.family: "JetBrains Mono"
                font.pixelSize: 11

                MouseArea {
                    id: clockArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: bar.showTip(Qt.formatDateTime(clock.date, "dddd, d MMMM yyyy  ·  " + (settings.clock24h ? "HH:mm:ss" : "h:mm:ss ap")), clockArea, mouseX)
                    onExited: bar.hideTip()
                }
            }

            Rectangle {
                id: gear
                width: 24
                height: 24
                radius: 7
                color: settings.panelSoft
                border.width: 1
                border.color: settings.border

                Text {
                    anchors.centerIn: parent
                    text: "⚙"
                    color: settings.accentColor
                    font.pixelSize: 12
                }

                MouseArea {
                    id: gearArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: shell.toggleSettings()
                    onEntered: bar.showTip("TARDIS settings  ·  click to open", gearArea, mouseX)
                    onExited: bar.hideTip()
                }
            }
        }

        SystemClock {
            id: clock
            precision: SystemClock.Seconds
        }

        Audio {
            id: audio
        }

        // Pill-shaped tooltip, floating just below the bar on its own layer.
        PanelWindow {
            id: tipWindow
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }
            margins {
                top: settings.barHeight + 18
                left: 8
                right: 8
            }
            implicitHeight: 30
            color: "transparent"
            visible: bar.tipShown && bar.tipText.length > 0
            focusable: false
            exclusionMode: ExclusionMode.Ignore

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "tardis-bar-tooltip"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            Rectangle {
                id: pill
                anchors.verticalCenter: parent.verticalCenter
                height: 28
                width: Math.min(tipLabel.implicitWidth + 28, tipWindow.width - 8)
                radius: height / 2
                color: settings.panel
                opacity: 0.97
                border.width: 1
                border.color: settings.border
                x: Math.min(Math.max(4, bar.tipAnchorX - width / 2), tipWindow.width - width - 4)

                Text {
                    id: tipLabel
                    anchors.centerIn: parent
                    text: bar.tipText
                    color: settings.cream
                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                }
            }
        }
    }
}
