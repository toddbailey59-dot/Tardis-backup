import QtQuick 2.15
import QtQuick.Window 2.2
import SddmComponents 2.0

Rectangle {
    id: root

    width: Screen.width > 0 ? Screen.width : 1680
    height: Screen.height > 0 ? Screen.height : 1050
    color: "#06101f"

    readonly property color navy: "#07111f"
    readonly property color panel: "#0a1729"
    readonly property color panelDeep: "#071321"
    readonly property color gold: "#e5b64c"
    readonly property color brightGold: "#ffd36e"
    readonly property color dimGold: "#8a6a2f"
    readonly property color ink: "#f4e6c8"
    readonly property color mutedInk: "#9fb2c8"
    readonly property color danger: "#ff6b6b"

    readonly property int cardWidth: 600
    readonly property int cardHeight: 522
    readonly property int centerX: width > 2400 ? width / 4 : width / 2
    readonly property int cardX: centerX - cardWidth / 2
    readonly property int cardY: (height - cardHeight) / 2

    property var now: new Date()
    property int sessionIndex: sessionBox.index

    TextConstants { id: textConstants }

    function tryLogin() {
        statusText.text = "Engaging TARDIS..."
        statusText.color = brightGold
        sddm.login(userField.text, passField.text, sessionBox.index)
    }

    Connections {
        target: sddm
        onLoginSucceeded: {
            statusText.text = textConstants.loginSucceeded
            statusText.color = brightGold
        }
        onLoginFailed: {
            passField.text = ""
            statusText.text = textConstants.loginFailed
            statusText.color = danger
            passField.focus = true
        }
        onInformationMessage: {
            statusText.text = message
            statusText.color = danger
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    Image {
        anchors.fill: parent
        source: (config.background && config.background !== "") ? config.background : "background.jpg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    Rectangle {
        anchors.fill: parent
        color: navy
        opacity: 0.76
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: dimGold
        border.width: 1
        opacity: 0.35
        anchors.margins: 18
    }

    Rectangle {
        x: cardX - 22
        y: cardY - 22
        width: cardWidth + 44
        height: cardHeight + 44
        radius: 30
        color: "transparent"
        border.color: gold
        border.width: 2
        opacity: 0.12

        NumberAnimation on opacity {
            from: 0.08
            to: 0.26
            duration: 2800
            loops: Animation.Infinite
            easing.type: Easing.InOutSine
        }
    }

    Rectangle {
        id: card
        x: cardX
        y: cardY
        width: cardWidth
        height: cardHeight
        radius: 18
        color: panel
        border.color: dimGold
        border.width: 2

        Rectangle {
            anchors.fill: parent
            anchors.margins: 6
            radius: 13
            color: "transparent"
            border.color: gold
            border.width: 1
            opacity: 0.32
        }

        Column {
            anchors.fill: parent
            anchors.margins: 28
            spacing: 14

            Row {
                width: parent.width
                height: 58

                Column {
                    spacing: 2

                    Text {
                        text: "TARDIS"
                        color: brightGold
                        font.family: "JetBrains Mono"
                        font.pixelSize: 30
                        font.bold: true
                    }
                    Text {
                        text: sddm.hostName + " // SECURE LOGIN"
                        color: mutedInk
                        font.family: "JetBrains Mono"
                        font.pixelSize: 11
                    }
                }

                Item { width: 2; height: 1 }

                Column {
                    anchors.right: parent.right
                    spacing: 0

                    Text {
                        text: Qt.formatTime(root.now, "hh:mm:ss")
                        color: ink
                        font.family: "JetBrains Mono"
                        font.pixelSize: 28
                        font.bold: true
                    }
                    Text {
                        text: Qt.formatDate(root.now, "dddd, d MMMM yyyy")
                        color: mutedInk
                        font.family: "JetBrains Mono"
                        font.pixelSize: 11
                    }
                }
            }

            Rectangle {
                id: badge
                width: parent.width
                height: 96
                radius: 10
                color: panelDeep
                border.color: dimGold
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "╔═══════ POLICE BOX ═══════╗\n║       T.A.R.D.I.S        ║\n╚═══════════════════════════╝"
                    color: gold
                    font.family: "JetBrains Mono"
                    font.pixelSize: 15
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    lineHeight: 1.12
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    radius: 7
                    color: "transparent"
                    border.color: gold
                    border.width: 1
                    opacity: 0.18

                    NumberAnimation on opacity {
                        from: 0.08
                        to: 0.38
                        duration: 1900
                        loops: Animation.Infinite
                        easing.type: Easing.InOutSine
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 6

                Text {
                    text: "OPERATIVE"
                    color: brightGold
                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: true
                }

                TextBox {
                    id: userField
                    width: parent.width
                    height: 42
                    text: userModel.lastUser
                    color: panelDeep
                    borderColor: dimGold
                    focusColor: gold
                    hoverColor: dimGold
                    textColor: ink
                    font.family: "JetBrains Mono"
                    font.pixelSize: 15
                    KeyNavigation.backtab: layoutBox
                    KeyNavigation.tab: passField
                }
            }

            Column {
                width: parent.width
                spacing: 6

                Text {
                    text: "PASSCODE"
                    color: brightGold
                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    font.bold: true
                }

                PasswordBox {
                    id: passField
                    width: parent.width
                    height: 42
                    color: panelDeep
                    borderColor: dimGold
                    focusColor: gold
                    hoverColor: dimGold
                    textColor: ink
                    tooltipEnabled: true
                    tooltipText: textConstants.capslockWarning
                    tooltipFG: ink
                    tooltipBG: panel
                    font.family: "JetBrains Mono"
                    font.pixelSize: 15
                    KeyNavigation.backtab: userField
                    KeyNavigation.tab: loginButton

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.tryLogin()
                            event.accepted = true
                        }
                    }
                }
            }

            Button {
                id: loginButton
                width: parent.width
                height: 46
                text: "ENTER TARDIS"
                color: dimGold
                textColor: navy
                borderColor: brightGold
                pressedColor: gold
                activeColor: brightGold
                font.family: "JetBrains Mono"
                font.pixelSize: 14
                font.bold: true
                KeyNavigation.backtab: passField
                KeyNavigation.tab: sessionBox
                onClicked: root.tryLogin()
            }

            Text {
                id: statusText
                width: parent.width
                text: "Awaiting credentials, Doctor"
                color: mutedInk
                font.family: "JetBrains Mono"
                font.pixelSize: 12
                horizontalAlignment: Text.AlignHCenter
            }

            Row {
                width: parent.width
                height: 38
                spacing: 10

                Text {
                    text: "SESSION"
                    color: mutedInk
                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    anchors.verticalCenter: parent.verticalCenter
                }

                ComboBox {
                    id: sessionBox
                    width: 205
                    height: 34
                    model: sessionModel
                    index: sessionModel.lastIndex
                    color: panelDeep
                    borderColor: dimGold
                    focusColor: gold
                    textColor: ink
                    font.family: "JetBrains Mono"
                    font.pixelSize: 12
                    KeyNavigation.backtab: loginButton
                    KeyNavigation.tab: layoutBox
                }

                Text {
                    text: "LAYOUT"
                    color: mutedInk
                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    anchors.verticalCenter: parent.verticalCenter
                }

                LayoutBox {
                    id: layoutBox
                    width: 110
                    height: 34
                    color: panelDeep
                    borderColor: dimGold
                    focusColor: gold
                    textColor: ink
                    font.family: "JetBrains Mono"
                    font.pixelSize: 12
                    KeyNavigation.backtab: sessionBox
                    KeyNavigation.tab: userField
                }
            }

            Row {
                width: parent.width
                height: 34
                spacing: 10

                Button {
                    width: 118
                    height: 32
                    text: "REBOOT"
                    color: panelDeep
                    textColor: gold
                    borderColor: dimGold
                    pressedColor: dimGold
                    activeColor: gold
                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    onClicked: sddm.reboot()
                }

                Button {
                    width: 118
                    height: 32
                    text: "POWER OFF"
                    color: panelDeep
                    textColor: danger
                    borderColor: dimGold
                    pressedColor: dimGold
                    activeColor: danger
                    font.family: "JetBrains Mono"
                    font.pixelSize: 11
                    onClicked: sddm.powerOff()
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "HARROW, ON // STARDATE " + Qt.formatDate(root.now, "yyyy.MM.dd")
                    color: mutedInk
                    font.family: "JetBrains Mono"
                    font.pixelSize: 10
                }
            }
        }
    }

    Text {
        x: cardX
        y: cardY + cardHeight + 16
        text: "TARDIS ACCESS TERMINAL  //  AUTHORIZED PERSONNEL ONLY"
        color: dimGold
        font.family: "JetBrains Mono"
        font.pixelSize: 11
    }

    Component.onCompleted: {
        if (userField.text === "")
            userField.focus = true
        else
            passField.focus = true
    }
}
