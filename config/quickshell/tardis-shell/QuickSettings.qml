import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: quick
    property var shell
    property var settings: shell.settings
    property var audio: shell.audio

    anchors {
        top: true
        right: true
    }
    margins {
        top: settings.barHeight + 20
        right: 8
    }
    implicitWidth: 340
    implicitHeight: 430
    color: "transparent"
    visible: shell.quickOpen
    focusable: shell.quickOpen
    exclusionMode: ExclusionMode.Ignore
    screen: shell.currentScreen

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "tardis-quick"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    onVisibleChanged: {
        if (visible) quickCard.forceActiveFocus()
    }

    Rectangle {
        id: quickCard
        anchors.fill: parent
        focus: true
        radius: settings.cornerRadius
        color: settings.panel
        opacity: 0.97
        border.width: 2
        border.color: settings.border

        Column {
            anchors {
                fill: parent
                margins: 14
            }
            spacing: 12

            Text {
                text: "QUICK SETTINGS"
                color: settings.accentColor
                font.family: "JetBrains Mono"
                font.pixelSize: 13
                font.bold: true
                font.letterSpacing: 2
            }

            Rectangle {
                width: parent.width
                height: 74
                radius: Math.max(6, settings.cornerRadius - 4)
                color: settings.bg
                border.width: 1
                border.color: settings.border

                Column {
                    anchors {
                        fill: parent
                        margins: 10
                    }
                    spacing: 8

                    Text {
                        width: parent.width
                        text: audio.name
                        color: settings.text
                        font.family: "JetBrains Mono"
                        font.pixelSize: 10
                        elide: Text.ElideRight
                    }

                    Row {
                        width: parent.width
                        spacing: 8

                        UiButton {
                            width: 36
                            compact: true
                            label: "−"
                            settings: quick.settings
                            onClicked: audio.setVolume(audio.volume - 0.05)
                        }

                        Rectangle {
                            width: parent.width - 36 * 3 - 16
                            height: 34
                            radius: 8
                            color: settings.panelSoft
                            border.width: 1
                            border.color: settings.border

                            Rectangle {
                                anchors {
                                    left: parent.left
                                    top: parent.top
                                    bottom: parent.bottom
                                    margins: 3
                                }
                                width: Math.max(4, (parent.width - 6) * audio.volume)
                                radius: 6
                                color: audio.muted ? settings.red : settings.accentColor
                            }

                            Text {
                                anchors.centerIn: parent
                                text: audio.muted ? "MUTED" : Math.round(audio.volume * 100) + "%"
                                color: settings.cream
                                font.family: "JetBrains Mono"
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }

                        UiButton {
                            width: 36
                            compact: true
                            label: "+"
                            settings: quick.settings
                            onClicked: audio.setVolume(audio.volume + 0.05)
                        }

                        UiButton {
                            width: 44
                            compact: true
                            label: audio.muted ? "ON" : "M"
                            active: audio.muted
                            settings: quick.settings
                            onClicked: audio.toggleMute()
                        }
                    }
                }
            }

            ToggleRow {
                width: parent.width
                label: "Do not disturb"
                checked: settings.dnd
                settings: quick.settings
                onToggled: { settings.dnd = !settings.dnd; settings.save() }
            }

            Grid {
                width: parent.width
                columns: 2
                spacing: 8

                UiButton {
                    width: (parent.width - 8) / 2
                    label: "LOCK"
                    settings: quick.settings
                    onClicked: { shell.run(["hyprlock"]); shell.closeQuick() }
                }

                UiButton {
                    width: (parent.width - 8) / 2
                    label: "SHOT"
                    settings: quick.settings
                    onClicked: { shell.screenshotFull(); shell.closeQuick() }
                }

                UiButton {
                    width: (parent.width - 8) / 2
                    label: "REGION"
                    settings: quick.settings
                    onClicked: { shell.screenshotRegion(); shell.closeQuick() }
                }

                UiButton {
                    width: (parent.width - 8) / 2
                    label: "SETTINGS"
                    settings: quick.settings
                    onClicked: { shell.closeQuick(); shell.openSettings() }
                }

                UiButton {
                    width: (parent.width - 8) / 2
                    label: "RELOAD SHELL"
                    settings: quick.settings
                    onClicked: { shell.reload(); shell.closeQuick() }
                }

                UiButton {
                    width: (parent.width - 8) / 2
                    label: "CLOSE"
                    settings: quick.settings
                    onClicked: shell.closeQuick()
                }
            }

            Text {
                width: parent.width
                text: "TARDIS SHELL // " + Qt.formatTime(shell.now, "HH:mm:ss")
                color: settings.muted
                font.family: "JetBrains Mono"
                font.pixelSize: 9
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                shell.closeQuick()
                event.accepted = true
            }
        }
    }
}
