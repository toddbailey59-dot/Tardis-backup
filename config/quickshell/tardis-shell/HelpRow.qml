import QtQuick

Rectangle {
    id: helpRow

    property string keys: ""
    property string description: ""
    property var settings
    property bool alternate: false

    height: 28
    radius: 6
    color: {
        if (alternate && settings) return settings.panelSoft
        if (alternate) return "#123a6b"
        return "transparent"
    }

    Text {
        anchors {
            left: parent.left
            leftMargin: 6
            verticalCenter: parent.verticalCenter
        }
        width: 170
        text: helpRow.keys
        color: settings ? settings.accentColor : "#e5b64c"
        font.family: "JetBrains Mono"
        font.pixelSize: 11
        font.bold: true
        elide: Text.ElideRight
    }

    Text {
        anchors {
            left: parent.left
            leftMargin: 184
            right: parent.right
            rightMargin: 6
            verticalCenter: parent.verticalCenter
        }
        text: helpRow.description
        color: settings ? settings.text : "#efe5c6"
        font.family: "JetBrains Mono"
        font.pixelSize: 11
        elide: Text.ElideRight
    }
}
