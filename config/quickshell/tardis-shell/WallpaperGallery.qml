import QtQuick
import Quickshell
import Quickshell.Io

Modal {
    id: gallery
    title: "WALLPAPER GALLERY"
    cardWidth: 1120
    cardHeight: 700
    open: shell ? shell.galleryOpen : false
    onCloseRequested: shell.closeGallery()

    property var shell
    property var settings: shell ? shell.settings : null
    readonly property int columns: 3

    property int selected: 0

    function pretty(name) {
        const labels = {
            "space-arp142": "ARP 142",
            "space-m81m82": "M81 / M82",
            "space-rosette": "ROSETTE",
            "space-w39": "W39",
            "space-whirlpool": "WHIRLPOOL"
        }
        if (labels[name]) return labels[name]
        return String(name).replace(/^space-/, "").replace(/-/g, " ").toUpperCase()
    }

    function selectedName() {
        return pairsModel.count > 0 ? pairsModel.get(selected).name : ""
    }

    function selectedPreview() {
        return pairsModel.count > 0 ? pairsModel.get(selected).preview : ""
    }

    function move(delta) {
        if (pairsModel.count === 0) return
        selected = (selected + delta + pairsModel.count) % pairsModel.count
    }

    function applyPair(name) {
        if (!name || !shell) return
        shell.run([Quickshell.env("HOME") + "/bin/wp-apply", name])
        shell.closeGallery()
    }

    function reload() {
        pairsModel.clear()
        loader.exec(["sh", Quickshell.shellPath("wallpapers.sh")])
    }

    onOpenChanged: {
        if (open) {
            reload()
            keySink.forceActiveFocus()
        }
    }

    ListModel {
        id: pairsModel
    }

    Process {
        id: loader
        stdout: StdioCollector {
            onStreamFinished: {
                let currentIndex = -1
                const lines = this.text.trim().split("\n")
                for (const line of lines) {
                    const parts = String(line).trim().split("|")
                    if (parts.length < 3) continue
                    pairsModel.append({
                        name: parts[0],
                        preview: parts[1],
                        isCurrent: parts[2] === "1"
                    })
                    if (parts[2] === "1") currentIndex = pairsModel.count - 1
                }
                gallery.selected = currentIndex >= 0 ? currentIndex : 0
            }
        }
    }

    Item {
        id: keySink
        focus: true
        Keys.onPressed: event => {
            let handled = true
            switch (event.key) {
                case Qt.Key_Escape:
                    shell.closeGallery()
                    break
                case Qt.Key_Return:
                case Qt.Key_Enter:
                    gallery.applyPair(gallery.selectedName())
                    break
                case Qt.Key_Left:
                    gallery.move(-1)
                    break
                case Qt.Key_Right:
                    gallery.move(1)
                    break
                case Qt.Key_Up:
                    gallery.move(-gallery.columns)
                    break
                case Qt.Key_Down:
                    gallery.move(gallery.columns)
                    break
                default:
                    handled = false
            }
            if (handled) event.accepted = true
        }
        Component.onCompleted: forceActiveFocus()
    }

    Row {
        anchors.fill: parent
        spacing: 16

        Column {
            width: 740
            height: parent.height
            spacing: 8

            Text {
                width: parent.width
                text: "CLICK OR PRESS ENTER TO APPLY  ·  ARROWS TO MOVE  ·  ESC TO CLOSE"
                color: settings ? settings.muted : "#9aa8c0"
                font.family: "JetBrains Mono"
                font.pixelSize: 10
                font.letterSpacing: 1
            }

            GridView {
                id: pairsGrid
                width: parent.width
                height: parent.height - 24
                cellWidth: 240
                cellHeight: 184
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                model: pairsModel

                delegate: Rectangle {
                    required property string name
                    required property string preview
                    required property bool isCurrent
                    required property int index

                    property bool selected: gallery.selected === index

                    width: pairsGrid.cellWidth - 12
                    height: pairsGrid.cellHeight - 12
                    radius: settings ? Math.max(6, settings.cornerRadius - 4) : 8
                    color: selected ? (settings ? settings.accentColor : "#22558f") : (settings ? settings.panelSoft : "#123a6b")
                    border.width: selected ? 3 : 1
                    border.color: selected ? (settings ? settings.cream : "#efe5c6") : (settings ? settings.border : "#22558f")

                    Rectangle {
                        anchors {
                            fill: parent
                            margins: 4
                        }
                        radius: 5
                        clip: true
                        color: settings ? settings.bg : "#0a1424"

                        Image {
                            anchors.fill: parent
                            source: "file://" + preview
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                        }

                        Rectangle {
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                            }
                            height: 30
                            color: "#cc0a1424"

                            Text {
                                anchors {
                                    left: parent.left
                                    leftMargin: 8
                                    verticalCenter: parent.verticalCenter
                                }
                                text: gallery.pretty(name)
                                color: selected && settings ? settings.bg : (settings ? settings.cream : "#efe5c6")
                                font.family: "JetBrains Mono"
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }

                        Rectangle {
                            anchors {
                                top: parent.top
                                right: parent.right
                                margins: 6
                            }
                            visible: isCurrent
                            width: 66
                            height: 18
                            radius: 4
                            color: settings ? settings.gold : "#e5b64c"
                            Text {
                                anchors.centerIn: parent
                                text: "CURRENT"
                                color: settings ? settings.bg : "#0a1424"
                                font.family: "JetBrains Mono"
                                font.pixelSize: 8
                                font.bold: true
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            gallery.selected = index
                            gallery.applyPair(name)
                        }
                    }
                }
            }
        }

        Column {
            width: 330
            height: parent.height
            spacing: 10

            Text {
                text: "PREVIEW"
                color: settings ? settings.accentColor : "#e5b64c"
                font.family: "JetBrains Mono"
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 2
            }

            Rectangle {
                width: parent.width
                height: 206
                radius: settings ? Math.max(6, settings.cornerRadius - 4) : 8
                clip: true
                color: settings ? settings.bg : "#0a1424"
                border.width: 1
                border.color: settings ? settings.border : "#22558f"

                Image {
                    anchors.fill: parent
                    source: gallery.selectedPreview() ? "file://" + gallery.selectedPreview() : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }

            Text {
                width: parent.width
                text: gallery.pretty(gallery.selectedName())
                color: settings ? settings.cream : "#efe5c6"
                font.family: "JetBrains Mono"
                font.pixelSize: 15
                font.bold: true
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: "Dual-monitor pair\nApplied to DP-3 and HDMI-A-1"
                color: settings ? settings.muted : "#9aa8c0"
                font.family: "JetBrains Mono"
                font.pixelSize: 10
                lineHeight: 1.5
            }

            Item { height: 4 }

            UiButton {
                width: parent.width
                label: "APPLY WALLPAPER"
                settings: gallery.settings
                active: true
                onClicked: gallery.applyPair(gallery.selectedName())
            }

            Text {
                width: parent.width
                text: pairsModel.count + " pairs available"
                color: settings ? settings.muted : "#9aa8c0"
                font.family: "JetBrains Mono"
                font.pixelSize: 10
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
