import QtQuick
import Quickshell.Networking

Item {
    id: root

    property var networks: []

    readonly property int checkMs: 500
    readonly property int timeoutMs: 2500

    property var state: ({ ssid: "", kind: "", fromPrompt: false, start: 0,
                          failureSsid: "", failureReason: "" })

    readonly property bool busy: state.kind !== ""
    readonly property string busySsid: busy ? state.ssid : ""
    readonly property string busyKind: state.kind
    readonly property string failureSsid: state.failureSsid
    readonly property string failureReason: state.failureReason

    signal needsRefresh
    signal failed(string ssid, bool fromPrompt)

    function replace(props) {
        const next = {}
        for (const k in state) next[k] = state[k]
        for (const k in props) next[k] = props[k]
        return next
    }

    function networkForSsid(ssid) {
        for (const n of networks) {
            if (n && n.name === ssid) return n
        }
        return null
    }

    function start(ssid, kind, fromPrompt) {
        if (busy) return
        state = { ssid: ssid, kind: kind, fromPrompt: fromPrompt,
                 start: Date.now(), failureSsid: "", failureReason: "" }
        actionCheck.start()
    }

    function cancel() {
        actionCheck.stop()
        state = { ssid: "", kind: "", fromPrompt: false, start: 0,
                 failureSsid: "", failureReason: "" }
    }

    function clearFailure() {
        if (state.failureSsid === "" && state.failureReason === "") return
        state = replace({ failureSsid: "", failureReason: "" })
    }

    function check() {
        if (!busy) return
        needsRefresh()
        const net = networkForSsid(state.ssid)
        if (!net) {
            cancel()
            return
        }
        if (state.kind === "connect") {
            if (net.connected) {
                const hadFailure = state.failureSsid === state.ssid
                actionCheck.stop()
                state = replace({
                    ssid: "", kind: "", fromPrompt: false,
                    failureSsid: hadFailure ? "" : state.failureSsid,
                    failureReason: hadFailure ? "" : state.failureReason
                })
                return
            }
            if (!net.stateChanging
                    && net.state === ConnectionState.Disconnected
                    && Date.now() - state.start > timeoutMs) {
                fail()
            }
        } else if (state.kind === "disconnect" && !net.connected) {
            actionCheck.stop()
            state = replace({ ssid: "", kind: "", fromPrompt: false })
        }
    }

    function fail() {
        const ssid = state.ssid
        const fromPrompt = state.fromPrompt
        actionCheck.stop()
        state = { ssid: "", kind: "", fromPrompt: false, start: 0,
                 failureSsid: ssid,
                 failureReason: fromPrompt ? "Wrong password" : "Connection failed" }
        failed(ssid, fromPrompt)
    }

    Timer {
        id: actionCheck
        interval: root.checkMs
        repeat: true
        onTriggered: root.check()
    }
}
