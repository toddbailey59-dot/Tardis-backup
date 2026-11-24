import QtQuick
import Quickshell
import Quickshell.Io

Modal {
    id: clipboard
    title: "CLIPBOARD HISTORY"
    cardWidth: 640
    cardHeight: 520
    open: shell ? shell.clipboardOpen : false
    onCloseRequested: shell.closeClipboard()

    property var shell
    property var settings: shell ? shell.settings : null
    property string lastValue: ""

    readonly property ListModel history: ListModel {}

    Process {
        id: clipboardWatcher
        command: ["wl-paste", "--watch", "--no-newline"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                const value = String(data).trim()
                if (!value || value === clipboard.lastValue) return
                clipboard.lastValue = value
                clipboard.history.insert(0, { value: value })
                while (clipboard.history.count > 40) clipboard.history.remove(clipboard.history.count - 1)
            }
        }
    }

    Component.onCompleted: {
        history.append({ value: "Clipboard history is live — copy anything to begin." })
    }

    Column {
        anchors.fill: parent
        spacing: 8

        Text {
            width: parent.width
            text: "Newest first · click to copy"
            color: settings ? settings.muted : "#9aa8c0"
            font.family: "JetBrains Mono"
            font.pixelSize: 10
        }

        Flickable {
            width: parent.width
            height: parent.height - 28
            contentHeight: clipColumn.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: clipColumn
                width: parent.width
                spacing: 6

                Repeater {
                    model: clipboard.history

                    delegate: Rectangle {
                        required property string value
                        width: clipColumn.width
                        implicitHeight: clipText.implicitHeight + 18
                        radius: settings ? Math.max(6, settings.cornerRadius - 5) : 8
                        color: settings ? settings.panelSoft : "#123a6b"
                        border.width: 1
                        border.color: settings ? settings.border : "#22558f"

                        Text {
                            id: clipText
                            anchors {
                                left: parent.left
                                right: parent.right
                                margins: 9
                            }
                            text: value
                            color: settings ? settings.text : "#efe5c6"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 11
                            wrapMode: Text.WrapAnywhere
                            maximumLineCount: 4
                            elide: Text.ElideRight
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                clipboard.copy(value)
                                clipboard.closeRequested()
                            }
                        }
                    }
                }
            }
        }
    }

    function copy(value) {
        if (!value || value.indexOf("Clipboard history is live") === 0) return
        shell.copyToClipboard(value)
    }
}
