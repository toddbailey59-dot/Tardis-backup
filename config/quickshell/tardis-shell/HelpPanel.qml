import QtQuick

Modal {
    id: helpPanel
    title: "KEYBINDS // SUPER + H"
    cardWidth: 940
    cardHeight: 720
    open: shell ? shell.helpOpen : false
    onCloseRequested: shell.closeHelp()

    property var shell
    property var settings: shell ? shell.settings : null

    Flickable {
        anchors.fill: parent
        contentHeight: columns.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Row {
            id: columns
            width: parent.width
            spacing: 16

            Column {
                width: (columns.width - 16) / 2
                spacing: 4

                Text {
                    text: "SHELL / PANELS"
                    color: settings ? settings.gold : "#e5b64c"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 12
                    font.bold: true
                    topPadding: 4
                    bottomPadding: 6
                }

                HelpRow { width: parent.width; keys: "SUPER + A"; description: "Application launcher"; settings: helpPanel.settings }
                HelpRow { width: parent.width; keys: "SUPER + D"; description: "Quick settings / OSD"; settings: helpPanel.settings; alternate: true }
                HelpRow { width: parent.width; keys: "SUPER + N"; description: "Notification center"; settings: helpPanel.settings }
                HelpRow { width: parent.width; keys: "SUPER + K"; description: "Power menu"; settings: helpPanel.settings; alternate: true }
                HelpRow { width: parent.width; keys: "SUPER + I"; description: "JARVIS chat window"; settings: helpPanel.settings }
                HelpRow { width: parent.width; keys: "SUPER + SHIFT + V"; description: "Clipboard history"; settings: helpPanel.settings; alternate: true }
                HelpRow { width: parent.width; keys: "SUPER + H"; description: "This keybinds overlay"; settings: helpPanel.settings }
                HelpRow { width: parent.width; keys: "SUPER + TAB"; description: "Overview forward"; settings: helpPanel.settings; alternate: true }
                HelpRow { width: parent.width; keys: "SUPER + SHIFT + TAB"; description: "Overview backward"; settings: helpPanel.settings }

                Text {
                    text: "APPS / TERMINALS"
                    color: settings ? settings.gold : "#e5b64c"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 12
                    font.bold: true
                    topPadding: 12
                    bottomPadding: 6
                }

                HelpRow { width: parent.width; keys: "SUPER + T"; description: "alacritty terminal"; settings: helpPanel.settings; alternate: true }
                HelpRow { width: parent.width; keys: "SUPER + Q"; description: "kitty terminal"; settings: helpPanel.settings }
                HelpRow { width: parent.width; keys: "SUPER + SHIFT + T"; description: "Scratchpad terminal"; settings: helpPanel.settings; alternate: true }
                HelpRow { width: parent.width; keys: "SUPER + G"; description: "OpenCode floating AI panel"; settings: helpPanel.settings }
                HelpRow { width: parent.width; keys: "SUPER + ALT + A"; description: "Local AI chat (llama-chat)"; settings: helpPanel.settings; alternate: true }
                HelpRow { width: parent.width; keys: "SUPER + F"; description: "Firefox"; settings: helpPanel.settings }
                HelpRow { width: parent.width; keys: "SUPER + B"; description: "Librewolf"; settings: helpPanel.settings; alternate: true }
                HelpRow { width: parent.width; keys: "SUPER + E"; description: "Thunar file manager"; settings: helpPanel.settings }
                HelpRow { width: parent.width; keys: "SUPER + SHIFT + E"; description: "VS Code (TARDIS workspace)"; settings: helpPanel.settings; alternate: true }
                HelpRow { width: parent.width; keys: "SUPER + O"; description: "Local AI web UI (Open WebUI)"; settings: helpPanel.settings }
                HelpRow { width: parent.width; keys: "SUPER + C"; description: "TARDIS calendar"; settings: helpPanel.settings; alternate: true }
                HelpRow { width: parent.width; keys: "SUPER + R"; description: "Spoken morning brief"; settings: helpPanel.settings }
                HelpRow { width: parent.width; keys: "SUPER + SHIFT + N"; description: "netcheck → workspace 2"; settings: helpPanel.settings; alternate: true }
                HelpRow { width: parent.width; keys: "SUPER + SHIFT + H"; description: "hostcheck → workspace 3"; settings: helpPanel.settings }
                HelpRow { width: parent.width; keys: "SUPER + M"; description: "Both monitor webapps"; settings: helpPanel.settings; alternate: true }
            }

            Column {
                width: (columns.width - 16) / 2
                spacing: 4

                Text {
                    text: "SYSTEM / WINDOWS"
                    color: settings ? settings.gold : "#e5b64c"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 12
                    font.bold: true
                    topPadding: 4
                    bottomPadding: 6
                }

                HelpRow { width: parent.width; keys: "SUPER + L"; description: "Lock screen"; settings: helpPanel.settings }
                HelpRow { width: parent.width; keys: "SUPER + SHIFT + M"; description: "TARDIS shutdown (5s)"; settings: helpPanel.settings; alternate: true }
                HelpRow { width: parent.width; keys: "SUPER + W"; description: "Next wallpaper pair"; settings: helpPanel.settings }
                HelpRow { width: parent.width; keys: "SUPER + SHIFT + W"; description: "Wallpaper gallery"; settings: helpPanel.settings; alternate: true }
                HelpRow { width: parent.width; keys: "SUPER + J"; description: "Toggle split layout"; settings: helpPanel.settings }
                HelpRow { width: parent.width; keys: "SUPER + P"; description: "Pseudo-tile"; settings: helpPanel.settings; alternate: true }
                HelpRow { width: parent.width; keys: "SUPER + V"; description: "Toggle floating"; settings: helpPanel.settings }
                HelpRow { width: parent.width; keys: "SUPER + S"; description: "Scratchpad toggle"; settings: helpPanel.settings; alternate: true }
                HelpRow { width: parent.width; keys: "SUPER + SHIFT + S"; description: "Move to scratchpad"; settings: helpPanel.settings }
                HelpRow { width: parent.width; keys: "SUPER + C"; description: "Close window"; settings: helpPanel.settings; alternate: true }
                HelpRow { width: parent.width; keys: "SUPER + SHIFT + Q"; description: "Close window (alt)"; settings: helpPanel.settings }

                Text {
                    text: "WORKSPACES / MOUSE"
                    color: settings ? settings.gold : "#e5b64c"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 12
                    font.bold: true
                    topPadding: 12
                    bottomPadding: 6
                }

                HelpRow { width: parent.width; keys: "SUPER + 1-0"; description: "Switch workspace"; settings: helpPanel.settings; alternate: true }
                HelpRow { width: parent.width; keys: "SUPER + SHIFT + 1-0"; description: "Move window to workspace"; settings: helpPanel.settings }
                HelpRow { width: parent.width; keys: "SUPER + arrows"; description: "Move focus"; settings: helpPanel.settings; alternate: true }
                HelpRow { width: parent.width; keys: "SUPER + scroll"; description: "Prev / next workspace"; settings: helpPanel.settings }
                HelpRow { width: parent.width; keys: "SUPER + drag"; description: "Move / resize window"; settings: helpPanel.settings; alternate: true }

                Text {
                    text: "SCREENSHOTS / MEDIA"
                    color: settings ? settings.gold : "#e5b64c"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 12
                    font.bold: true
                    topPadding: 12
                    bottomPadding: 6
                }

                HelpRow { width: parent.width; keys: "Print"; description: "Full screenshot"; settings: helpPanel.settings }
                HelpRow { width: parent.width; keys: "SHIFT + Print"; description: "Region screenshot"; settings: helpPanel.settings; alternate: true }
                HelpRow { width: parent.width; keys: "SUPER + Print"; description: "Focused window screenshot"; settings: helpPanel.settings }
                HelpRow { width: parent.width; keys: "SUPER + SHIFT + C"; description: "Pick color (clipboard)"; settings: helpPanel.settings; alternate: true }
                HelpRow { width: parent.width; keys: "Volume keys"; description: "Volume up / down / mute"; settings: helpPanel.settings }
                HelpRow { width: parent.width; keys: "Media keys"; description: "Play / pause / next / prev"; settings: helpPanel.settings; alternate: true }
            }
        }
    }
}
