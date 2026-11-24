import QtQuick

Rectangle {
    id: button

    property string label: ""
    property var settings
    property bool active: false
    property bool compact: false

    signal clicked()

    height: compact ? 34 : 42
    radius: settings ? Math.max(6, settings.cornerRadius - 4) : 8
    color: {
        if (active && settings) return settings.accentColor
        if (settings) return settings.panelSoft
        return "#123a6b"
    }
    border.width: 1
    border.color: settings ? settings.border : "#22558f"

    Text {
        anchors.centerIn: parent
        text: button.label
        color: active && settings ? settings.bg : (settings ? settings.text : "#efe5c6")
        font.family: "JetBrains Mono"
        font.pixelSize: compact ? 11 : 13
        font.bold: active
        elide: Text.ElideRight
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: button.clicked()
    }
}
