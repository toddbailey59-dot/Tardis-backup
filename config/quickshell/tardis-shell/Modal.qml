import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: modal

    property var settings
    property bool open: false
    property string title: ""
    property int cardWidth: 640
    property int cardHeight: 480

    signal closeRequested()

    default property alias content: contentArea.data

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    margins {
        top: 0
        bottom: 0
        left: 0
        right: 0
    }
    color: "transparent"
    visible: open
    focusable: open
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "tardis-modal"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Rectangle {
        anchors.fill: parent
        color: "#9a020817"

        MouseArea {
            anchors.fill: parent
            onClicked: modal.closeRequested()
        }
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(modal.cardWidth, parent.width - 32)
        height: Math.min(modal.cardHeight, parent.height - 32)
        radius: modal.settings ? modal.settings.cornerRadius : 12
        color: modal.settings ? modal.settings.panel : "#0d1b31"
        border.width: 2
        border.color: modal.settings ? modal.settings.border : "#22558f"

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                modal.closeRequested()
                event.accepted = true
            }
        }

        Component.onCompleted: forceActiveFocus()

        Rectangle {
            id: header
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: 48
            color: modal.settings ? modal.settings.bg : "#0a1424"
            radius: card.radius

            Text {
                anchors {
                    left: parent.left
                    leftMargin: 16
                    verticalCenter: parent.verticalCenter
                }
                text: modal.title
                color: modal.settings ? modal.settings.accentColor : "#e5b64c"
                font.family: "JetBrains Mono"
                font.pixelSize: 14
                font.bold: true
                font.letterSpacing: 2
            }

            Rectangle {
                anchors {
                    right: parent.right
                    rightMargin: 12
                    verticalCenter: parent.verticalCenter
                }
                width: 28
                height: 28
                radius: 8
                color: modal.settings ? modal.settings.panelSoft : "#123a6b"

                Text {
                    anchors.centerIn: parent
                    text: "×"
                    color: modal.settings ? modal.settings.text : "#efe5c6"
                    font.pixelSize: 18
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: modal.closeRequested()
                }
            }
        }

        Item {
            id: contentArea
            anchors {
                top: header.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 14
            }
        }
    }

    onOpenChanged: {
        if (open) card.forceActiveFocus()
    }
}
