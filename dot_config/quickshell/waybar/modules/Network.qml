import QtQuick
import Quickshell.Io
import Quickshell.Networking

ModuleBox {
    id: root
    color: "#cda6f7"

    readonly property var wifiIcons: ["\u{F092F}", "\u{F091F}", "\u{F0922}", "\u{F0925}", "\u{F0928}"]

    property bool loaded: false

    readonly property var activeDev: findActive()
    readonly property string iface: activeDev !== null ? activeDev.name : ""
    readonly property int wifiPct: activeDev !== null && activeDev.type === DeviceType.Wifi
        ? wifiSignalPct(activeDev) : 0
    readonly property string wifiLabel: wifiIcons[Math.min(4, Math.floor(wifiPct / 20))]
        + "  " + wifiPct + "%"

    property string ethRate: "0.0o/s"
    property string ethIface: ""
    property var prevIface: null
    property var prevRx: null
    readonly property string ethLabel: (iface !== "" && iface === ethIface)
        ? "\uF063: " + ethRate : "\uF063: 0.0o/s"

    readonly property string label: activeDev === null ? "\u{F092E}"
        : (activeDev.type === DeviceType.Wifi ? wifiLabel : ethLabel)

    visible: loaded

    function findActive() {
        let wifi = null
        let wired = null
        for (const d of Networking.devices.values) {
            if (d.type === DeviceType.Wifi && d.connected) wifi = d
            else if (d.type === DeviceType.Wired && d.connected) wired = d
        }
        return wired || wifi
    }

    function wifiSignalPct(dev) {
        for (const n of dev.networks.values) {
            if (n.connected) {
                return Math.max(0, Math.min(100, Math.round(n.signalStrength * 100)))
            }
        }
        return 0
    }

    function powFormatOctets(bps) {
        const units = ["", "k", "M", "G", "T", "P"]
        let fraction = bps
        let pow = 0
        while (pow < 5 && fraction / 1000 >= 1) {
            fraction /= 1000
            pow++
        }
        return fraction.toFixed(1) + units[pow] + "o/s"
    }

    function parseNetDev(text) {
        const out = {}
        for (const line of text.split("\n")) {
            const idx = line.indexOf(":")
            if (idx < 0) continue
            const name = line.slice(0, idx).trim()
            const parts = line.slice(idx + 1).trim().split(/\s+/)
            if (parts.length < 9) continue
            out[name] = Number(parts[0])
        }
        return out
    }

    function nextSample(ifname, prevIface, prevRx, rx) {
        if (ifname === "" || rx === null) {
            return { prevIface: null, prevRx: null, rate: null }
        }
        if (prevIface !== ifname || prevRx === null) {
            return { prevIface: ifname, prevRx: rx, rate: "0.0o/s" }
        }
        const delta = rx - prevRx
        return { prevIface: ifname, prevRx: rx,
                 rate: delta < 0 ? "0.0o/s" : powFormatOctets(Math.floor(delta / 5)) }
    }

    function onSample(text) {
        const cur = parseNetDev(text)
        const dev = findActive()
        const ifname = (dev !== null && dev.type === DeviceType.Wired) ? dev.name : ""
        const rx = (ifname !== "" && ifname in cur) ? cur[ifname] : null
        const r = nextSample(ifname, prevIface, prevRx, rx)
        prevIface = r.prevIface
        prevRx = r.prevRx
        if (r.rate === null) {
            ethIface = ""
            return
        }
        ethRate = r.rate
        ethIface = ifname
    }

    Process {
        id: proc
        command: ["cat", "/proc/net/dev"]
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
            id: loadCheckTimer
            interval: 1000
            repeat: true
            running: true
            onTriggered: {
                if (Networking.devices.values.length > 0) root.loaded = true
            }
        }
        Timer {
            id: loadTimeout
            interval: 10000
            running: true
            onTriggered: root.loaded = true
        }
    }

    Component.onCompleted: {
        proc.running = true
        sampleTimer.start()
    }

    BarText {
        color: root.color
        text: root.label
    }
}
