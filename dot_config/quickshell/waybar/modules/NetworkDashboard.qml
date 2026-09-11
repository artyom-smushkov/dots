import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Hyprland

PopupWindow {
    id: root
    implicitWidth: screenW
    implicitHeight: screenH
    color: "transparent"
    visible: false
    mask: Region {
        x: 0
        y: 0
        width: root.screenW
        height: root.screenH
        shape: RegionShape.Rect
    }

    property var anchorItem: null

    readonly property var scr: (screen && screen.width > 0) ? screen
        : (QsWindow.window ? QsWindow.window.screen : null)
    readonly property int screenW: scr ? scr.width : 0
    readonly property int screenH: scr ? scr.height : 0

    readonly property int padding: 14
    readonly property color fg: "#cdd6f4"
    readonly property color fgDim: "#a6adc8"
    readonly property color accent: "#cda6f7"
    readonly property color ok: "#a6e3a1"
    readonly property color error: "#f38ba8"
    readonly property color surface: "#313244"
    readonly property color borderColor: "#45475a"
    readonly property color bg: Qt.rgba(30/255, 30/255, 46/255, 0.95)
    readonly property int pollMs: 2000

    readonly property var wifiDevice: utils.findDevice(DeviceType.Wifi)
    readonly property var wiredDevice: utils.findDevice(DeviceType.Wired)
    readonly property var wifiNetworkObjects: networkObjects()
    property var connectedWifi: null

    readonly property string kind: (wiredDevice && wiredDevice.connected) ? "ethernet"
        : connectedWifi ? "wifi" : "disconnected"
    readonly property int wifiPct: connectedWifi
        ? Math.round(connectedWifi.signalStrength * 100) : 0
    readonly property string headerIcon: kind === "ethernet" ? "\uF063"
        : kind === "wifi" ? utils.signalIcon(wifiPct) : "\u{F092E}"
    readonly property string headerTitle: kind === "wifi"
        ? (connectedWifi ? connectedWifi.name : "Wi-Fi")
        : kind === "ethernet" ? wiredDevice.name : "Not connected"
    readonly property string headerSub: kind === "wifi"
        ? (connectedWifi ? "Wi-Fi  " + wifiPct + "%" : "Wi-Fi")
        : kind === "ethernet" ? "Ethernet" : "No active connection"

    ListModel { id: wifiModel }
    property var scannerDevice: null
    property string lastRowsKey: ""

    property string passwordSsid: ""

    property var info: ({})
    property string prevIface: ""
    property real prevRx: 0
    property real prevTx: 0
    property real prevTime: 0
    property real downRate: 0
    property real upRate: 0

    function anchorPos() {
        if (!QsWindow.window || !anchorItem) return null
        try {
            return QsWindow.mapFromItem(anchorItem, 0, 0)
        } catch (e) {
            return null
        }
    }

    readonly property real popupX: {
        const p = anchorPos()
        if (p === null) return 0
        const x = p.x + anchorItem.width / 2 - box.implicitWidth / 2
        return Math.max(4, Math.min(x, screenW - box.implicitWidth - 4))
    }
    readonly property real popupY: QsWindow.window ? QsWindow.window.height + 7 : 0

    anchor {
        window: QsWindow.window
        rect.x: 0
        rect.y: 0
    }

    readonly property string pingText: (info.ping_gw || info.ping_net)
        ? utils.formatPing(info.ping_gw) + "  " + utils.formatPing(info.ping_net) : "--"
    readonly property string speedText: "↓ " + utils.formatRate(downRate) + "  ↑ " + utils.formatRate(upRate)
    readonly property string totalText: utils.formatBytes(info.rx) + "  /  " + utils.formatBytes(info.tx)
    readonly property int vpnCount: Number(info.vpn_count || 0)
    readonly property bool vpnActive: vpnCount > 0

    readonly property string detailsScriptPath:
        String(Quickshell.env("HOME")) + "/.config/quickshell/waybar/scripts/net_details.sh"

    function networkObjects() {
        const dev = wifiDevice
        if (!dev || !dev.networks) return []
        const v = dev.networks.values
        return v ? v : []
    }

    function open() {
        if (visible) return
        info = {}
        prevIface = ""
        prevTime = 0
        downRate = 0
        upRate = 0
        controller.clearFailure()
        visible = true
        Qt.callLater(function() {
            grab.active = true
            catcher.forceActiveFocus()
        })
        setScanner(true)
        syncWifiNetworks()
        if (!detailsProc.running) detailsProc.running = true
    }

    function close() {
        if (!visible) return
        visible = false
        grab.active = false
        setScanner(false)
        cancelPassword()
        controller.cancel()
    }

    function toggle() { visible ? close() : open() }

    function setScanner(enabled) {
        if (scannerDevice && scannerDevice !== wifiDevice)
            scannerDevice.scannerEnabled = false
        scannerDevice = wifiDevice
        if (scannerDevice) scannerDevice.scannerEnabled = enabled
    }

    function toggleWifi() {
        if (Networking.backend !== NetworkBackendType.NetworkManager) return
        Networking.wifiEnabled = !Networking.wifiEnabled
    }

    function syncWifiNetworks() {
        let conn = null
        const rows = []
        for (const n of networkObjects()) {
            if (!n) continue
            if (n.connected) conn = n
            rows.push({
                ssid: n.name || "",
                connected: !!n.connected,
                known: !!n.known,
                signal: Math.round((n.signalStrength || 0) * 100),
                secured: n.security !== WifiSecurityType.Open
                    && n.security !== WifiSecurityType.Owe
            })
        }
        rows.sort(function(a, b) {
            if (a.connected !== b.connected) return a.connected ? -1 : 1
            if (a.known !== b.known) return a.known ? -1 : 1
            return b.signal - a.signal
        })
        connectedWifi = conn
        const key = JSON.stringify(rows)
        if (key === lastRowsKey) return
        lastRowsKey = key
        wifiModel.clear()
        wifiModel.append(rows)
    }

    function networkForSsid(ssid) {
        for (const n of networkObjects()) {
            if (n && n.name === ssid) return n
        }
        return null
    }

    function onRowClicked(ssid) {
        if (controller.busy) return
        const net = networkForSsid(ssid)
        if (!net) return
        if (net.connected) {
            controller.start(ssid, "disconnect", false)
            net.disconnect()
            return
        }
        cancelPassword()
        if (!net.known
                && net.security !== WifiSecurityType.Open
                && net.security !== WifiSecurityType.Owe) {
            passwordSsid = ssid
            return
        }
        controller.start(ssid, "connect", false)
        net.connect()
    }

    function submitPassword() {
        const net = networkForSsid(passwordSsid)
        if (!net || controller.busy) return
        controller.start(passwordSsid, "connect", true)
        net.connectWithPsk(prompt.field.text)
    }

    function cancelPassword() {
        passwordSsid = ""
    }

    function updateDetails(text) {
        const next = utils.parseKeyValue(text)
        if (!next.iface) {
            info = {}
            return
        }
        info = next
        const now = Date.now() / 1000
        const rx = Number(next.rx || 0)
        const tx = Number(next.tx || 0)
        if (next.iface === prevIface && prevTime > 0) {
            const dt = now - prevTime
            if (dt > 0) {
                downRate = Math.max(0, (rx - prevRx) / dt)
                upRate = Math.max(0, (tx - prevTx) / dt)
            }
        }
        prevIface = next.iface
        prevRx = rx
        prevTx = tx
        prevTime = now
    }

    onWifiDeviceChanged: {
        setScanner(visible)
        syncWifiNetworks()
    }

    onWifiNetworkObjectsChanged: syncWifiNetworks()

    onPasswordSsidChanged: {
        if (passwordSsid === "")
            Qt.callLater(function() { catcher.forceActiveFocus() })
    }

    Component.onDestruction: {
        if (scannerDevice) scannerDevice.scannerEnabled = false
    }

    MouseArea {
        id: catcher
        anchors.fill: parent
        focus: true
        onPressed: root.close()
        Keys.onEscapePressed: root.close()
    }

    Rectangle {
        id: box
        x: popupX
        y: popupY
        implicitWidth: Math.max(380, contentCol.implicitWidth + 2 * root.padding)
        width: implicitWidth
        implicitHeight: contentCol.implicitHeight + 2 * root.padding
        color: root.bg
        border.color: root.borderColor
        border.width: 2

        ColumnLayout {
            id: contentCol
            x: root.padding
            y: root.padding
            width: box.width - 2 * root.padding
            spacing: 10

            RowLayout {
                spacing: 8

                BarText {
                    color: kind === "disconnected" ? root.fgDim : root.accent
                    text: headerIcon
                }

                ColumnLayout {
                    spacing: 0
                    BarText { color: root.fg; text: headerTitle }
                    BarText { color: root.fgDim; text: headerSub }
                }

                Layout.fillWidth: true

                Item {
                    width: wifiToggleText.implicitWidth
                    height: wifiToggleText.implicitHeight
                    BarText {
                        id: wifiToggleText
                        color: Networking.wifiEnabled ? root.ok : root.error
                        text: "Wi-Fi " + (Networking.wifiEnabled ? "on" : "off")
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toggleWifi()
                    }
                }

                Item {
                    width: 24
                    height: 24
                    BarText {
                        anchors.centerIn: parent
                        color: root.fgDim
                        text: "\uF15C"
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.close()
                    }
                }
            }

            ColumnLayout {
                spacing: 4
                visible: info.iface !== ""

                GridLayout {
                    columns: 2
                    columnSpacing: 12
                    rowSpacing: 4

                    RowLayout {
                        spacing: 6
                        BarText { color: root.fgDim; text: "IP" }
                        BarText { color: root.fg; text: info.ip || "--" }
                    }
                    RowLayout {
                        spacing: 6
                        BarText { color: root.fgDim; text: "GW" }
                        BarText { color: root.fg; text: info.gateway || "--" }
                    }
                    RowLayout {
                        spacing: 6
                        BarText { color: root.fgDim; text: "Ping" }
                        BarText { color: root.fg; text: pingText }
                    }
                    RowLayout {
                        spacing: 6
                        BarText { color: root.fgDim; text: "Speed" }
                        BarText { color: root.fg; text: speedText }
                    }
                    RowLayout {
                        spacing: 6
                        BarText { color: root.fgDim; text: "Total ↓/↑" }
                        BarText { color: root.fg; text: totalText }
                    }
                }
            }

            ColumnLayout {
                spacing: 4
                visible: root.vpnActive

                RowLayout {
                    spacing: 8
                    BarText { color: root.ok; text: "\u{F0465}" }
                    BarText { color: root.ok; text: info.vpn_name || "" }
                    BarText {
                        visible: root.vpnCount > 1
                        color: root.fgDim
                        text: "+" + (root.vpnCount - 1) + " more"
                    }
                    Layout.fillWidth: true
                }

                GridLayout {
                    columns: 2
                    columnSpacing: 12
                    rowSpacing: 4

                    RowLayout {
                        spacing: 6
                        BarText { color: root.fgDim; text: "IP" }
                        BarText { color: root.fg; text: info.vpn_ip || "--" }
                    }
                    RowLayout {
                        spacing: 6
                        BarText { color: root.fgDim; text: "Endpoint" }
                        BarText { color: root.fg; text: info.vpn_endpoint || "--" }
                    }
                    RowLayout {
                        spacing: 6
                        BarText { color: root.fgDim; text: "Total ↓/↑" }
                        BarText { color: root.fg; text: utils.formatBytes(info.vpn_rx) + "  /  " + utils.formatBytes(info.vpn_tx) }
                    }
                }
            }

            RowLayout {
                spacing: 6
                BarText { color: root.accent; text: "Wi-Fi" }
                BarText { color: root.fgDim; text: wifiModel.count + "" }
                Layout.fillWidth: true
            }

            WifiList {
                model: wifiModel
                busySsid: controller.busySsid
                busyKind: controller.busyKind
                failureSsid: controller.failureSsid
                failureReason: controller.failureReason
                dimColor: root.fgDim
                onRowClicked: (ssid) => root.onRowClicked(ssid)
            }

            PasswordPrompt {
                id: prompt
                ssid: root.passwordSsid
                fg: root.fg
                dim: root.fgDim
                surface: root.surface
                borderColor: root.borderColor
                onSubmitted: root.submitPassword()
                onCancelled: root.cancelPassword()
            }
        }
    }

    NetUtils {
        id: utils
    }

    NetActionController {
        id: controller
        networks: wifiNetworkObjects
        onNeedsRefresh: syncWifiNetworks()
        onFailed: (ssid, fromPrompt) => {
            if (fromPrompt)
                passwordSsid = ssid
        }
    }

    Process {
        id: detailsProc
        command: ["bash", root.detailsScriptPath]
        stdout: StdioCollector {
            onStreamFinished: root.updateDetails(text)
        }
    }

    HyprlandFocusGrab {
        id: grab
        windows: [root]
        active: false
    }

    Item {
        Timer {
            interval: root.pollMs
            repeat: true
            running: root.visible
            onTriggered: {
                if (!detailsProc.running) detailsProc.running = true
                root.syncWifiNetworks()
            }
        }
    }
}
