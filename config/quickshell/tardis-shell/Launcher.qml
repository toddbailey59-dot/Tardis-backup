import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets

Modal {
    id: launcher
    title: "APPLICATION LAUNCHER"
    cardWidth: 760
    cardHeight: 580
    open: shell ? shell.launcherOpen : false
    onCloseRequested: shell.closeLauncher()

    property var shell
    property var settings: shell ? shell.settings : null
    property int selectedIndex: 0

    property var filteredApps: {
        const query = searchField.text.trim().toLowerCase()
        const all = DesktopEntries.applications.values
        if (!query) return all.slice(0, 48)
        return all.filter(app => {
            const name = (app.name || "").toLowerCase()
            const id = (app.id || "").toLowerCase()
            const comment = (app.comment || "").toLowerCase()
            const keywords = (app.keywords || []).join(" ").toLowerCase()
            return name.indexOf(query) >= 0 || id.indexOf(query) >= 0 ||
                   comment.indexOf(query) >= 0 || keywords.indexOf(query) >= 0
        }).slice(0, 48)
    }

    onOpenChanged: {
        if (open) {
            searchField.text = ""
            selectedIndex = 0
            searchField.forceActiveFocus()
        }
    }

    onFilteredAppsChanged: selectedIndex = 0

    Column {
        anchors.fill: parent
        spacing: 10

        Rectangle {
            width: parent.width
            height: 42
            radius: settings ? Math.max(6, settings.cornerRadius - 4) : 8
            color: settings ? settings.bg : "#0a1424"
            border.width: 1
            border.color: settings ? settings.border : "#22558f"

            TextField {
                id: searchField
                anchors.fill: parent
                leftPadding: 14
                rightPadding: 14
                placeholderText: "Search applications…"
                color: settings ? settings.text : "#efe5c6"
                placeholderTextColor: settings ? settings.muted : "#9aa8c0"
                font.family: "JetBrains Mono"
                font.pixelSize: 13
                background: Item {}

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Down) {
                        selectedIndex = Math.min(filteredApps.length - 1, selectedIndex + 1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Up) {
                        selectedIndex = Math.max(0, selectedIndex - 1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (filteredApps.length > 0) launch(filteredApps[Math.max(0, selectedIndex)])
                        event.accepted = true
                    }
                }
            }
        }

        Text {
            width: parent.width
            text: filteredApps.length + " results"
            color: settings ? settings.muted : "#9aa8c0"
            font.family: "JetBrains Mono"
            font.pixelSize: 10
        }

        Flickable {
            width: parent.width
            height: parent.height - 42 - 10 - 22
            contentHeight: grid.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Grid {
                id: grid
                width: parent.width
                columns: settings ? settings.launcherColumns : 4
                spacing: 8

                Repeater {
                    model: launcher.filteredApps

                    delegate: Rectangle {
                        required property var modelData
                        property bool selected: launcher.filteredApps.indexOf(modelData) === launcher.selectedIndex

                        width: (grid.width - (grid.columns - 1) * grid.spacing) / grid.columns
                        height: 74
                        radius: settings ? Math.max(6, settings.cornerRadius - 5) : 8
                        color: selected ? (settings ? settings.accentColor : "#22558f") : (settings ? settings.panelSoft : "#123a6b")
                        border.width: selected ? 0 : 1
                        border.color: settings ? settings.border : "#22558f"

                        Column {
                            anchors {
                centerIn: parent
                                margins: 6
                            }
                            spacing: 6
                            width: parent.width - 12

                            IconImage {
                                anchors.horizontalCenter: parent.horizontalCenter
                                implicitSize: 26
                                source: Quickshell.iconPath(modelData.icon || "application-x-executable", "")
                                asynchronous: true
                            }

                            Text {
                                width: parent.width
                                text: modelData.name || modelData.id || "Application"
                                color: selected && settings ? settings.bg : (settings ? settings.text : "#efe5c6")
                                font.family: "JetBrains Mono"
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                launcher.selectedIndex = launcher.filteredApps.indexOf(modelData)
                                launch(modelData)
                            }
                        }
                    }
                }
            }
        }
    }

    function launch(app) {
        if (!app) return
        app.execute()
        shell.closeLauncher()
    }
}
