import QtQuick
import Quickshell.Io
import Quickshell.Networking

ModuleBox {
    id: root
    color: "#cda6f7"
    clickable: true

    readonly property int sampleIntervalMs: 5000

    property bool loaded: false

    readonly property var activeDev: findActive()
    readonly property string iface: activeDev !== null ? activeDev.name : ""
    readonly property int wifiPct: activeDev !== null && activeDev.type === DeviceType.Wifi
        ? wifiSignalPct(activeDev) : 0
    readonly property string wifiLabel: utils.signalIcon(wifiPct) + "  " + wifiPct + "%"

    property real wiredRate: -1
    property string wiredIface: ""
    property var prevIface: null
    property var prevRx: null
    readonly property string wiredLabel: "\uF063: "
        + (iface !== "" && iface === wiredIface ? utils.formatRate(wiredRate) : utils.formatRate(0))

    property string vpnIface: ""
    readonly property string vpnLabel: vpnIface !== "" ? "\u{F0465} " + vpnIface + "  " : ""

    readonly property string label: vpnLabel
        + (activeDev === null ? "\u{F092E}"
        : (activeDev.type === DeviceType.Wifi ? wifiLabel : wiredLabel))

    visible: loaded || Networking.devices.values.length > 0

    onClicked: dashboard.toggle()

    NetUtils {
        id: utils
    }

    NetworkDashboard {
        id: dashboard
        anchorItem: root
    }

    function findActive() {
        return utils.findConnected(DeviceType.Wired) || utils.findConnected(DeviceType.Wifi)
    }

    function wifiSignalPct(dev) {
        for (const n of dev.networks.values) {
            if (n.connected) {
                return Math.max(0, Math.min(100, Math.round(n.signalStrength * 100)))
            }
        }
        return 0
    }

    function nextSample(ifname, prevIface, prevRx, rx) {
        if (ifname === "" || rx === null) {
            return { prevIface: null, prevRx: null, rate: null }
        }
        if (prevIface !== ifname || prevRx === null) {
            return { prevIface: ifname, prevRx: rx, rate: 0 }
        }
        const delta = rx - prevRx
        return { prevIface: ifname, prevRx: rx,
                 rate: delta < 0 ? 0 : delta / (sampleIntervalMs / 1000) }
    }

    function handleNetDevSample(text) {
        const cur = utils.parseNetDev(text)
        const dev = findActive()
        const ifname = (dev !== null && dev.type === DeviceType.Wired) ? dev.name : ""
        const rx = (ifname !== "" && ifname in cur) ? cur[ifname] : null
        const r = nextSample(ifname, prevIface, prevRx, rx)
        prevIface = r.prevIface
        prevRx = r.prevRx
        if (r.rate === null) {
            wiredIface = ""
            wiredRate = -1
            return
        }
        wiredRate = r.rate
        wiredIface = ifname
    }

    function handleVpnSample(text) {
        let first = ""
        for (const line of text.split("\n")) {
            const m = line.match(/^\d+:\s*([a-zA-Z0-9_-]+):/)
            if (m) { first = m[1]; break }
        }
        vpnIface = first
    }

    Process {
        id: proc
        command: ["cat", "/proc/net/dev"]
        stdout: StdioCollector {
            onStreamFinished: root.handleNetDevSample(text)
        }
    }

    Process {
        id: vpnProc
        command: ["ip", "-o", "link", "show", "type", "wireguard"]
        stdout: StdioCollector {
            onStreamFinished: root.handleVpnSample(text)
        }
    }

    Item {
        Timer {
            id: sampleTimer
            interval: root.sampleIntervalMs
            repeat: true
            onTriggered: {
                proc.running = true
                vpnProc.running = true
            }
        }
        Timer {
            id: loadTimeout
            interval: 10000
            running: !root.loaded
            onTriggered: root.loaded = true
        }
    }

    Component.onCompleted: {
        proc.running = true
        vpnProc.running = true
        sampleTimer.start()
    }

    BarText {
        color: root.color
        text: root.label
    }
}
