import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
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
    readonly property color accent: "#74c7ec"
    readonly property color boost: "#f38ba8"
    readonly property color borderColor: "#45475a"
    readonly property color bg: Qt.rgba(30/255, 30/255, 46/255, 0.95)

    ListModel { id: sinkModel }
    ListModel { id: sourceModel }
    ListModel { id: playbackModel }
    ListModel { id: recordModel }
    property string sig: ""

    function anchorPos() {
        if (!QsWindow.window || !anchorItem) return null
        try {
            return QsWindow.mapFromItem(anchorItem, 0, 0)
        } catch (e) {
            return null
        }
    }

    property real anchorScreenX: 0
    property real anchorScreenW: 0
    readonly property int panelW: 480

    readonly property real popupX: {
        const cx = anchorScreenX + anchorScreenW / 2
        return Math.max(4, Math.min(cx - panelW / 2, screenW - panelW - 4))
    }
    readonly property real popupY: QsWindow.window ? QsWindow.window.height + 7 : 0

    anchor {
        window: QsWindow.window
        rect.x: 0
        rect.y: 0
    }

    function nodes() {
        const m = Pipewire.nodes
        return (m && m.values) ? m.values : []
    }

    function isSinkNode(n) {
        return n && (n.type & PwNodeType.Sink) !== 0 && (n.type & PwNodeType.Stream) === 0
    }
    function isSourceNode(n) {
        return n && (n.type & PwNodeType.Source) !== 0 && (n.type & PwNodeType.Stream) === 0
    }
    function isPlayback(n) {
        return n && (n.type & PwNodeType.Stream) !== 0 && (n.type & PwNodeType.Sink) !== 0
    }
    function isRecording(n) {
        return n && (n.type & PwNodeType.Stream) !== 0 && (n.type & PwNodeType.Source) !== 0
    }

    function collect(pred) {
        const out = []
        for (const n of nodes()) {
            if (n && pred(n)) out.push(n)
        }
        return out
    }
    function sigOf(arr) {
        return arr.map(function(n) { return n.id }).join(",")
    }
    function fillModel(model, arr, kind) {
        arr.sort(function(a, b) { return a.name.localeCompare(b.name) })
        model.clear()
        for (const n of arr) {
            model.append({ node: n, kind: kind })
        }
    }

    function resync() {
        const sinks = collect(isSinkNode)
        const sources = collect(isSourceNode)
        const playback = collect(isPlayback)
        const record = collect(isRecording)

        const newSig = sigOf(sinks) + "|" + sigOf(sources) + "|"
            + sigOf(playback) + "|" + sigOf(record)
        if (newSig === sig) return
        sig = newSig

        fillModel(sinkModel, sinks, "sink")
        fillModel(sourceModel, sources, "source")
        fillModel(playbackModel, playback, "playback")
        fillModel(recordModel, record, "recording")

        const all = []
        for (const n of nodes()) all.push(n)
        tracker.objects = all
    }

    function setDefault(node, isSinkNode) {
        if (!node) return
        if (isSinkNode) Pipewire.preferredDefaultAudioSink = node
        else Pipewire.preferredDefaultAudioSource = node
    }

    function open() {
        if (visible) return
        sig = ""
        const p = anchorPos()
        if (p !== null && anchorItem) {
            anchorScreenX = p.x
            anchorScreenW = anchorItem.width
        }
        visible = true
        Qt.callLater(function() {
            grab.active = true
            catcher.forceActiveFocus()
        })
        resync()
    }

    function close() {
        if (!visible) return
        visible = false
        grab.active = false
    }

    function toggle() { visible ? close() : open() }

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
        width: root.panelW
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
                    color: root.accent
                    text: "\uF028"
                }
                BarText {
                    color: root.fg
                    text: "Audio"
                }
                Layout.fillWidth: true

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
                visible: sinkModel.count > 0

                RowLayout {
                    spacing: 6
                    BarText { color: root.accent; text: "Output devices" }
                    BarText { color: root.fgDim; text: sinkModel.count + "" }
                    Layout.fillWidth: true
                }
                Repeater {
                    model: sinkModel
                    PulseRow {
                        Layout.fillWidth: true
                        node: model.node
                        kind: model.kind
                        isDefault: Pipewire.defaultAudioSink !== null
                            && Pipewire.defaultAudioSink.id === model.node.id
                        fg: root.fg
                        fgDim: root.fgDim
                        accent: root.accent
                        boost: root.boost
                        onDefaultRequested: root.setDefault(model.node, true)
                    }
                }
            }

            ColumnLayout {
                spacing: 4
                visible: sourceModel.count > 0

                RowLayout {
                    spacing: 6
                    BarText { color: root.accent; text: "Input devices" }
                    BarText { color: root.fgDim; text: sourceModel.count + "" }
                    Layout.fillWidth: true
                }
                Repeater {
                    model: sourceModel
                    PulseRow {
                        Layout.fillWidth: true
                        node: model.node
                        kind: model.kind
                        isDefault: Pipewire.defaultAudioSource !== null
                            && Pipewire.defaultAudioSource.id === model.node.id
                        fg: root.fg
                        fgDim: root.fgDim
                        accent: root.accent
                        boost: root.boost
                        onDefaultRequested: root.setDefault(model.node, false)
                    }
                }
            }

            ColumnLayout {
                spacing: 4
                visible: playbackModel.count > 0

                RowLayout {
                    spacing: 6
                    BarText { color: root.accent; text: "Playback" }
                    BarText { color: root.fgDim; text: playbackModel.count + "" }
                    Layout.fillWidth: true
                }
                Repeater {
                    model: playbackModel
                    PulseRow {
                        Layout.fillWidth: true
                        node: model.node
                        kind: model.kind
                        isDefault: false
                        fg: root.fg
                        fgDim: root.fgDim
                        accent: root.accent
                        boost: root.boost
                    }
                }
            }

            ColumnLayout {
                spacing: 4
                visible: recordModel.count > 0

                RowLayout {
                    spacing: 6
                    BarText { color: root.accent; text: "Recording" }
                    BarText { color: root.fgDim; text: recordModel.count + "" }
                    Layout.fillWidth: true
                }
                Repeater {
                    model: recordModel
                    PulseRow {
                        Layout.fillWidth: true
                        node: model.node
                        kind: model.kind
                        isDefault: false
                        fg: root.fg
                        fgDim: root.fgDim
                        accent: root.accent
                        boost: root.boost
                    }
                }
            }
        }
    }

    PwObjectTracker {
        id: tracker
        objects: []
    }

    HyprlandFocusGrab {
        id: grab
        windows: [root]
        active: false
    }

    Item {
        Timer {
            interval: 600
            repeat: true
            running: root.visible
            onTriggered: root.resync()
        }
    }
}
