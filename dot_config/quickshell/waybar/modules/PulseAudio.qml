import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire

ModuleBox {
    id: root
    color: "#74c7ec"
    clickable: true
    wheelable: true
    middleClickable: true

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property int sinkPct: sink !== null && sink.audio !== null
        ? Math.round(sink.audio.volume * 100) : 0
    readonly property bool sinkMuted: sink !== null && sink.audio !== null && sink.audio.muted
    readonly property int sourcePct: source !== null && source.audio !== null
        ? Math.round(source.audio.volume * 100) : 0
    readonly property bool sourceMuted: source !== null && source.audio !== null && source.audio.muted

    readonly property var sinkIcons: ["\uF026", "\uF027", "\uF028"]

    readonly property string sinkText: sinkMuted
        ? "\u{F075F} "
        : sinkIcons[Math.min(2, Math.floor(sinkPct / 33))] + " " + sinkPct + "% "

    readonly property string sourceText: sourceMuted
        ? "\uF131"
        : "\uF130 " + sourcePct + "%"

    readonly property real inputBoundary: sinkLabel.mapToItem(root, sinkLabel.width, 0).x

    function isInput(x) { return x >= inputBoundary }

    function nudgeVolume(delta, target) {
        if (target === null || target.audio === null) return
        target.audio.volume = Math.max(0, Math.min(1, Math.round((target.audio.volume + delta) * 100) / 100))
    }

    function toggleMuted(target) {
        if (target === null || target.audio === null) return
        target.audio.muted = !target.audio.muted
    }

    visible: sink !== null && sink.ready

    Item {
        PwObjectTracker {
            objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
        }
        Process {
            id: pavuProc
            command: ["sh", "-c", "pavucontrol &"]
        }
    }

    onClicked: pavuProc.running = true
    onWheelUp: nudgeVolume(0.05, isInput(x) ? source : sink)
    onWheelDown: nudgeVolume(-0.05, isInput(x) ? source : sink)
    onMiddleClicked: toggleMuted(isInput(x) ? source : sink)

    BarText {
        id: sinkLabel
        color: root.color
        text: root.sinkText
    }
    BarText {
        id: sourceLabel
        color: root.color
        text: root.sourceText
    }
}
