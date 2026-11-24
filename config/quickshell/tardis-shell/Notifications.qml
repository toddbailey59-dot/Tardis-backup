import QtQuick
import Quickshell
import Quickshell.Wayland

QtObject {
    id: notifications

    property var shell
    property var server
    property var settings: shell.settings

    readonly property ListModel popups: ListModel {}

    function addPopup(notif) {
        if (!notif || settings.dnd || notif.transient) return
        popups.insert(0, {
            notification: notif,
            compact: notif.appName === "TARDIS Volume"
        })
        while (popups.count > 4) popups.remove(popups.count - 1)
    }

    function clearAll() {
        const list = server.trackedNotifications.values.slice()
        for (const n of list) n.dismiss()
        popups.clear()
    }

    property PanelWindow popupPanel: PanelWindow {
        id: popupWindow
        property var popupSettings: settings

        anchors {
            top: true
            right: true
        }
        margins {
            top: settings.barHeight + 20
            right: 8
        }
        implicitWidth: 360
        implicitHeight: popupColumn.implicitHeight
        color: "transparent"
        visible: popups.count > 0
        focusable: false
        exclusionMode: ExclusionMode.Ignore
        screen: shell.currentScreen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "tardis-notification-popup"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        Column {
            id: popupColumn
            width: parent.width
            spacing: 8

            Repeater {
                model: popups

                delegate: Rectangle {
                    required property var notification
                    required property bool compact
                    required property int index

                    width: popupColumn.width
                    implicitHeight: inner.implicitHeight + 20
                    radius: settings.cornerRadius
                    color: settings.panel
                    opacity: 0.97
                    border.width: 2
                    border.color: settings.accentColor

                    Timer {
                        interval: settings.popupTimeout
                        running: true
                        onTriggered: popups.remove(index)
                    }

                    Column {
                        id: inner
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: 10
                        }
                        spacing: 4

                        Text {
                            width: parent.width
                            text: notification.appName || "System"
                            color: settings.accentColor
                            font.family: "JetBrains Mono"
                            font.pixelSize: 10
                            font.bold: true
                        }

                        Text {
                            width: parent.width
                            text: notification.summary || ""
                            color: settings.text
                            font.family: "JetBrains Mono"
                            font.pixelSize: 12
                            font.bold: true
                            wrapMode: Text.Wrap
                        }

                        Text {
                            width: parent.width
                            text: notification.body || ""
                            color: settings.muted
                            font.family: "JetBrains Mono"
                            font.pixelSize: 10
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            shell.openNotifications()
                            popups.remove(index)
                        }
                    }
                }
            }
        }
    }

    property PanelWindow centerPanel: PanelWindow {
        id: centerWindow
        anchors {
            top: true
            right: true
        }
        margins {
            top: settings.barHeight + 20
            right: 8
        }
        implicitWidth: 400
        implicitHeight: 560
        color: "transparent"
        visible: shell.notificationsOpen
        focusable: shell.notificationsOpen
        exclusionMode: ExclusionMode.Ignore
        screen: shell.currentScreen

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "tardis-notification-center"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        onVisibleChanged: {
            if (visible) centerCard.forceActiveFocus()
        }

        Rectangle {
            id: centerCard
            anchors.fill: parent
            focus: true
            radius: settings.cornerRadius
            color: settings.panel
            opacity: 0.98
            border.width: 2
            border.color: settings.border

            Column {
                anchors {
                    fill: parent
                    margins: 12
                }
                spacing: 10

                Row {
                    width: parent.width
                    height: 28

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "NOTIFICATIONS"
                        color: settings.accentColor
                        font.family: "JetBrains Mono"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Item { width: 20; height: 1 }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "CLEAR ALL"
                        color: settings.muted
                        font.family: "JetBrains Mono"
                        font.pixelSize: 10

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: notifications.clearAll()
                        }
                    }
                }

                Flickable {
                    width: parent.width
                    height: parent.height - 38
                    contentHeight: listColumn.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: listColumn
                        width: parent.width
                        spacing: 8

                        Repeater {
                            model: server.trackedNotifications

                            delegate: Rectangle {
                                required property var modelData
                                width: listColumn.width
                                implicitHeight: bodyColumn.implicitHeight + 16
                                radius: Math.max(6, settings.cornerRadius - 4)
                                color: settings.bg
                                border.width: 1
                                border.color: settings.border

                                Column {
                                    id: bodyColumn
                                    anchors {
                                        left: parent.left
                                        right: parent.right
                                        top: parent.top
                                        margins: 8
                                    }
                                    spacing: 4

                                    Row {
                                        width: parent.width

                                        Text {
                                            text: modelData.appName || "System"
                                            color: settings.accentColor
                                            font.family: "JetBrains Mono"
                                            font.pixelSize: 10
                                            font.bold: true
                                        }

                                        Item { width: 8; height: 1 }

                                        Text {
                                            text: "×"
                                            color: settings.muted
                                            font.pixelSize: 14

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: modelData.dismiss()
                                            }
                                        }
                                    }

                                    Text {
                                        width: parent.width
                                        text: modelData.summary || ""
                                        color: settings.text
                                        font.family: "JetBrains Mono"
                                        font.pixelSize: 11
                                        font.bold: true
                                        wrapMode: Text.Wrap
                                    }

                                    Text {
                                        width: parent.width
                                        text: modelData.body || ""
                                        color: settings.muted
                                        font.family: "JetBrains Mono"
                                        font.pixelSize: 10
                                        wrapMode: Text.Wrap
                                    }

                                    Row {
                                        width: parent.width
                                        spacing: 6
                                        Repeater {
                                            model: modelData.actions
                                            delegate: UiButton {
                                                label: modelData.text || "Action"
                                                compact: true
                                                settings: notifications.settings
                                                onClicked: modelData.invoke()
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            width: listColumn.width
                            visible: server.trackedNotifications.values.length === 0
                            text: "No notifications"
                            color: settings.muted
                            font.family: "JetBrains Mono"
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    shell.closeNotifications()
                    event.accepted = true
                }
            }
        }
    }
}
