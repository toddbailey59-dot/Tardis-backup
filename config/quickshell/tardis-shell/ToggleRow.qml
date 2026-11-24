import QtQuick

Rectangle {
    id: row

    property string label: ""
    property bool checked: false
    property var settings

    signal toggled()

    height: 42
    color: "transparent"

    Text {
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        text: row.label
        color: settings ? settings.text : "#efe5c6"
        font.family: "JetBrains Mono"
        font.pixelSize: 12
    }

    Rectangle {
        id: track
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        width: 44
        height: 24
        radius: 12
        color: row.checked ? (settings ? settings.accentColor : "#22558f") : "#0a1424"
        border.width: 1
        border.color: settings ? settings.border : "#22558f"

        Rectangle {
            width: 18
            height: 18
            radius: 9
            x: row.checked ? 23 : 3
            y: 2
            color: settings ? settings.cream : "#efe5c6"

            Behavior on x {
                NumberAnimation {
                    duration: row.settings && row.settings.animate ? 120 : 0
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: row.toggled()
        }
    }
}
