import QtQuick
import Quickshell.Io

QtObject {
    id: helper
    property string pending: ""

    property Process process: Process {
        id: copyProcess
        command: ["wl-copy"]
        stdinEnabled: true

        onStarted: {
            if (helper.pending) {
                copyProcess.write(helper.pending)
                helper.pending = ""
            }
        }

        onExited: {
            if (helper.pending) copyProcess.running = true
        }
    }

    function copy(text) {
        helper.pending = String(text)
        copyProcess.running = false
        copyProcess.running = true
    }
}
