import QtQuick

Modal {
    id: power
    title: "POWER"
    cardWidth: 420
    cardHeight: 430
    open: shell ? shell.powerOpen : false
    onCloseRequested: shell.closePower()

    property var shell
    property var settings: shell ? shell.settings : null

    Column {
        anchors {
            fill: parent
            margins: 10
        }
        spacing: 10

        UiButton {
            width: parent.width
            label: "LOCK SESSION"
            settings: power.settings
            onClicked: { shell.run(["hyprlock"]); shell.closeOverlays() }
        }

        UiButton {
            width: parent.width
            label: "LOGOUT"
            settings: power.settings
            onClicked: { shell.run(["hyprctl", "dispatch", "exit"]); shell.closeOverlays() }
        }

        UiButton {
            width: parent.width
            label: "SUSPEND"
            settings: power.settings
            onClicked: { shell.run(["systemctl", "suspend"]); shell.closeOverlays() }
        }

        UiButton {
            width: parent.width
            label: "REBOOT"
            active: true
            settings: power.settings
            onClicked: { shell.run(["systemctl", "reboot"]); shell.closeOverlays() }
        }

        UiButton {
            width: parent.width
            label: "SHUTDOWN"
            active: true
            settings: power.settings
            onClicked: { shell.run(["systemctl", "poweroff"]); shell.closeOverlays() }
        }

        Text {
            width: parent.width
            text: "ESC or click outside to cancel"
            color: settings ? settings.muted : "#9aa8c0"
            font.family: "JetBrains Mono"
            font.pixelSize: 10
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
