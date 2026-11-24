import QtQuick

Rectangle {
    id: row

    property string label: ""
    property int value: 0
    property int minimum: 0
    property int maximum: 100
    property int step: 1
    property var settings

    signal changed(int newValue)

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

    Row {
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        spacing: 6

        Rectangle {
            width: 28
            height: 28
            radius: 8
            color: settings ? settings.panelSoft : "#123a6b"
            border.width: 1
            border.color: settings ? settings.border : "#22558f"
            Text {
                anchors.centerIn: parent
                text: "−"
                color: settings ? settings.text : "#efe5c6"
                font.pixelSize: 14
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: row.changed(Math.max(row.minimum, row.value - row.step))
            }
        }

        Text {
            width: 48
            text: String(row.value)
            color: settings ? settings.cream : "#efe5c6"
            font.family: "JetBrains Mono"
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: 28
            height: 28
            radius: 8
            color: settings ? settings.panelSoft : "#123a6b"
            border.width: 1
            border.color: settings ? settings.border : "#22558f"
            Text {
                anchors.centerIn: parent
                text: "+"
                color: settings ? settings.text : "#efe5c6"
                font.pixelSize: 14
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: row.changed(Math.min(row.maximum, row.value + row.step))
            }
        }
    }
}
