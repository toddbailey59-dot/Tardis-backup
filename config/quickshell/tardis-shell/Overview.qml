import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

Modal {
    id: overview
    title: "WORKSPACE OVERVIEW"
    cardWidth: 1120
    cardHeight: 720
    open: shell ? shell.overviewOpen : false
    onCloseRequested: shell.closeOverview()

    property var shell
    property var settings: shell ? shell.settings : null
    property var workspaces: Hyprland.workspaces.values.filter(ws => ws.id > 0)

    Grid {
        anchors.fill: parent
        columns: 5
        rows: 2
        spacing: 12

        Repeater {
            model: overview.workspaces

            delegate: Rectangle {
                required property var modelData
                property int position: overview.workspaces.indexOf(modelData)
                property bool selected: position === shell.overviewIndex
                property bool active: modelData.active
                property var windows: Hyprland.toplevels.values.filter(t => t.workspace && t.workspace.id === modelData.id)

                width: (parent.width - 4 * 12) / 5
                height: (parent.height - 12) / 2
                radius: settings ? Math.max(6, settings.cornerRadius - 4) : 8
                color: selected ? (settings ? settings.accentColor : "#22558f") : (settings ? settings.panelSoft : "#123a6b")
                border.width: selected ? 3 : (active ? 2 : 1)
                border.color: selected ? (settings ? settings.cream : "#efe5c6") : (settings ? settings.border : "#22558f")

                Column {
                    anchors {
                        fill: parent
                        margins: 10
                    }
                    spacing: 8

                    Row {
                        width: parent.width

                        Text {
                            text: "WS " + modelData.id
                            color: selected && settings ? settings.bg : (settings ? settings.cream : "#efe5c6")
                            font.family: "JetBrains Mono"
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Item { width: 8; height: 1 }

                        Text {
                            text: active ? "ACTIVE" : (modelData.monitor ? modelData.monitor.name : "")
                            color: selected && settings ? settings.bg : (settings ? settings.muted : "#9aa8c0")
                            font.family: "JetBrains Mono"
                            font.pixelSize: 9
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Item {
                        width: parent.width
                        height: parent.height - 26

                        Column {
                            width: parent.width
                            height: parent.height
                            spacing: 6

                            Repeater {
                                model: windows.slice(0, 3)

                                delegate: Rectangle {
                                    required property var modelData
                                    width: parent.width
                                    height: Math.min(110, (parent.height - 12) / 3)
                                    radius: 6
                                    color: settings ? settings.bg : "#0a1424"
                                    clip: true
                                    border.width: 1
                                    border.color: settings ? settings.border : "#22558f"

                                    ScreencopyView {
                                        anchors.fill: parent
                                        visible: modelData.handle !== null
                                        captureSource: modelData.handle
                                        live: true
                                        constraintSize: Qt.size(180, 110)
                                    }

                                    Text {
                                        anchors {
                                            left: parent.left
                                            right: parent.right
                                            bottom: parent.bottom
                                            margins: 4
                                        }
                                        text: modelData.title || "Window"
                                        color: settings ? settings.cream : "#efe5c6"
                                        font.family: "JetBrains Mono"
                                        font.pixelSize: 9
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            Text {
                                width: parent.width
                                height: 20
                                visible: windows.length === 0
                                text: "EMPTY"
                                color: settings ? settings.muted : "#9aa8c0"
                                font.family: "JetBrains Mono"
                                font.pixelSize: 11
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        shell.overviewIndex = position
                        modelData.activate()
                        shell.closeOverview()
                    }
                }
            }
        }
    }

    Text {
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            bottomMargin: -2
        }
        text: "SUPER+TAB / SHIFT+TAB cycle · ENTER or click to activate · ESC to close"
        color: settings ? settings.muted : "#9aa8c0"
        font.family: "JetBrains Mono"
        font.pixelSize: 9
        horizontalAlignment: Text.AlignHCenter
    }
}
