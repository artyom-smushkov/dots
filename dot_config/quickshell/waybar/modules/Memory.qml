import QtQuick
import Quickshell.Io

ModuleBox {
    id: root
    color: "#a6e3a1"
    tooltipText: tooltip

    property string label: ""
    property string tooltip: ""

    function formatGiB(hundredths) {
        const ip = Math.floor(hundredths / 100)
        const fp = hundredths % 100
        if (fp === 0) return String(ip)
        return String(ip) + "." + String(fp).padStart(2, "0").replace(/0$/, "")
    }

    function onSample(text) {
        let memTotal = 0
        let memAvailable = 0
        for (const line of text.split("\n")) {
            let m = line.match(/^MemTotal:\s+(\d+)/)
            if (m) memTotal = Number(m[1])
            m = line.match(/^MemAvailable:\s+(\d+)/)
            if (m) memAvailable = Number(m[1])
        }
        if (memTotal <= 0) return
        const hundredths = Math.round((memTotal - memAvailable) / 10485.76)
        label = formatGiB(hundredths) + "GiB"
        tooltip = (hundredths / 100).toFixed(1) + "GiB used"
    }

    Process {
        id: proc
        command: ["cat", "/proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: root.onSample(text)
        }
    }

    Item {
        Timer {
            id: sampleTimer
            interval: 5000
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
        text: "\uEFC5  " + root.label
    }
}
