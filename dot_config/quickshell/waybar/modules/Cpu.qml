import QtQuick
import Quickshell.Io

ModuleBox {
    id: root
    color: "#cdd6f4"
    tooltipText: tooltip

    property int usage: 0
    property string tooltip: ""
    property var prevSample: null

    function parseStat(text) {
        const cores = []
        let total = null
        for (const line of text.split("\n")) {
            if (!line.startsWith("cpu")) break
            const parts = line.trim().split(/\s+/)
            const times = parts.slice(1).map(Number)
            if (times.length < 5) continue
            const idle = times[3] + times[4]
            let tot = 0
            for (const t of times) tot += t
            if (parts[0] === "cpu") total = [idle, tot]
            else cores.push([idle, tot])
        }
        return { total: total, cores: cores }
    }

    function onSample(text) {
        const cur = parseStat(text)
        if (cur.total === null) return
        if (prevSample === null) {
            prevSample = cur
            primeTimer.start()
            return
        }
        const dTotal = cur.total[1] - prevSample.total[1]
        if (cur.cores.length !== prevSample.cores.length) {
            if (dTotal > 0)
                usage = Math.floor(100 * (1 - (cur.total[0] - prevSample.total[0]) / dTotal))
            tooltip = "Total: " + usage + "%\nCores: (pending)"
            prevSample = cur
            return
        }
        if (dTotal <= 0) {
            prevSample = cur
            return
        }
        usage = Math.floor(100 * (1 - (cur.total[0] - prevSample.total[0]) / dTotal))
        let tip = "Total: " + usage + "%"
        for (let i = 0; i < cur.cores.length; i++) {
            const cct = cur.cores[i][1]
            const ppt = prevSample.cores[i][1]
            if (cct === 0 || ppt === 0) {
                tip += "\nCore" + i + ": offline"
                continue
            }
            const cu = Math.floor(100 * (1 - (cur.cores[i][0] - prevSample.cores[i][0]) / (cct - ppt)))
            tip += "\nCore" + i + ": " + cu + "%"
        }
        tooltip = tip
        prevSample = cur
    }

    Process {
        id: proc
        command: ["cat", "/proc/stat"]
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
        Timer {
            id: primeTimer
            interval: 100
            onTriggered: proc.running = true
        }
    }

    Component.onCompleted: {
        proc.running = true
        sampleTimer.start()
    }

    BarText {
        color: root.color
        text: "\uF2DB  " + String(root.usage).padStart(2, " ") + "%"
    }
}
