import QtQuick
import Quickshell.Io

ModuleBox {
    id: root
    color: "#94e2d5"
    tooltipText: tooltip

    property string label: ""
    property string tooltip: ""

    function powFormat(bytes) {
        const units = ["", "k", "M", "G", "T", "P"]
        let fraction = bytes
        let pow = 0
        while (pow < 5 && fraction / 1024 >= 1) {
            fraction /= 1024
            pow++
        }
        return fraction.toFixed(1) + units[pow] + (pow > 0 ? "i" : "") + "B"
    }

    function onSample(text) {
        let size = 0
        let used = 0
        let avail = 0
        for (const line of text.split("\n")) {
            const m = line.trim().match(/^(\d+)\s+(\d+)\s+(\d+)$/)
            if (m) {
                size = Number(m[1])
                used = Number(m[2])
                avail = Number(m[3])
            }
        }
        if (size <= 0) return
        label = powFormat(avail)
        tooltip = powFormat(used) + " used out of " + powFormat(size) +
                  " on /home/ (" + Math.floor(used * 100 / size) + "%)"
    }

    Process {
        id: proc
        command: ["df", "--output=size,used,avail", "-B1", "/home"]
        stdout: StdioCollector {
            onStreamFinished: root.onSample(text)
        }
    }

    Item {
        Timer {
            id: sampleTimer
            interval: 30000
            repeat: true
            onTriggered: proc.running = true
        }
    }

    Component.onCompleted: {
        proc.running = true
        sampleTimer.start()
    }

    BarText {
        color: root.color
        text: "\u{F02CA}  " + root.label
    }
}
