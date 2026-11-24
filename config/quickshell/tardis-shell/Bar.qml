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

        Row {
            anchors {
                left: parent.left
                leftMargin: 12
                verticalCenter: parent.verticalCenter
            }
            spacing: 6

            Text {
                text: "◈ TARDIS"
                color: settings.accentColor
                font.family: "JetBrains Mono"
                font.pixelSize: 12
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
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
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: modelData.activate()
                    }
                }
            }
        }

        Text {
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
        }

        Row {
            anchors {
                right: parent.right
                rightMargin: 12
                verticalCenter: parent.verticalCenter
            }
            spacing: 10

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: settings.showWeather
                text: shell.stats.weatherText
                color: settings.accentColor
                font.family: "JetBrains Mono"
                font.pixelSize: 11
                font.bold: true
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: settings.showSysStats
                text: shell.stats.sysText
                color: settings.muted
                font.family: "JetBrains Mono"
                font.pixelSize: 10
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: audio.available
                    ? (audio.muted ? "◌ MUTE" : "◖ " + Math.round(audio.volume * 100) + "%")
                    : "◌ AUDIO"
                color: audio.muted ? settings.red : settings.muted
                font.family: "JetBrains Mono"
                font.pixelSize: 11
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: shell.notificationCount > 0 ? "● " + shell.notificationCount : "○"
                color: shell.notificationCount > 0 ? settings.accentColor : settings.muted
                font.family: "JetBrains Mono"
                font.pixelSize: 11

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: shell.toggleNotifications()
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Qt.formatTime(clock.date, settings.clock24h ? "HH:mm" : "h:mm ap") +
                      (settings.clockSeconds ? ":" + Qt.formatTime(clock.date, "ss") : "") +
                      "  " + Qt.formatDate(clock.date, "ddd d MMM")
                color: settings.cream
                font.family: "JetBrains Mono"
                font.pixelSize: 11
            }

            Rectangle {
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
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: shell.toggleSettings()
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
    }
}
