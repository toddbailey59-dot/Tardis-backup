import QtQuick
import QtQuick.Controls

Modal {
    id: chat
    title: "JARVIS // OPENCODE"
    cardWidth: 620
    cardHeight: 460
    open: shell ? shell.chatOpen : false
    onCloseRequested: shell.closeChat()

    property var shell
    property var settings: shell ? shell.settings : null

    onOpenChanged: {
        if (open) promptField.forceActiveFocus()
    }

    Column {
        anchors {
            fill: parent
            margins: 12
        }
        spacing: 12

        Rectangle {
            width: parent.width
            height: 90
            radius: settings ? Math.max(6, settings.cornerRadius - 4) : 8
            color: settings ? settings.bg : "#0a1424"
            border.width: 1
            border.color: settings ? settings.border : "#22558f"

            Text {
                anchors {
                    fill: parent
                    margins: 12
                }
                text: "TARDIS AI console. Type a prompt, or launch a full OpenCode session.\nSUPER+G opens the floating terminal session directly."
                color: settings ? settings.muted : "#9aa8c0"
                font.family: "JetBrains Mono"
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
        }

        Rectangle {
            width: parent.width
            height: 48
            radius: settings ? Math.max(6, settings.cornerRadius - 4) : 8
            color: settings ? settings.bg : "#0a1424"
            border.width: 1
            border.color: settings ? settings.border : "#22558f"

            TextField {
                id: promptField
                anchors.fill: parent
                leftPadding: 12
                rightPadding: 12
                placeholderText: "Ask OpenCode…"
                color: settings ? settings.text : "#efe5c6"
                placeholderTextColor: settings ? settings.muted : "#9aa8c0"
                font.family: "JetBrains Mono"
                font.pixelSize: 12
                background: Item {}

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        const text = promptField.text.trim()
                        if (text) chat.ask(text)
                        event.accepted = true
                    }
                }
            }
        }

        Grid {
            width: parent.width
            columns: 2
            spacing: 8

            UiButton {
                width: (parent.width - 8) / 2
                label: "ASK OPENCODE"
                active: true
                settings: chat.settings
                onClicked: {
                    const text = promptField.text.trim()
                    if (text) chat.ask(text)
                }
            }

            UiButton {
                width: (parent.width - 8) / 2
                label: "OPEN FULL SESSION"
                settings: chat.settings
                onClicked: {
                    shell.run(["kitty", "--class", "ai", "-e", "opencode"])
                    shell.closeOverlays()
                }
            }

            UiButton {
                width: (parent.width - 8) / 2
                label: "REVIEW DIFF"
                settings: chat.settings
                onClicked: chat.ask("Review the current git diff and suggest improvements.")
            }

            UiButton {
                width: (parent.width - 8) / 2
                label: "COMMIT MSG"
                settings: chat.settings
                onClicked: chat.ask("Write a concise conventional commit message for the current changes.")
            }
        }

        Text {
            width: parent.width
            text: "Prompts launch in a kitty window with class 'ai'."
            color: settings ? settings.muted : "#9aa8c0"
            font.family: "JetBrains Mono"
            font.pixelSize: 10
            horizontalAlignment: Text.AlignHCenter
        }
    }

    function ask(text) {
        shell.run(["kitty", "--class", "ai", "-e", "opencode", "--prompt", text])
        shell.closeOverlays()
    }
}
