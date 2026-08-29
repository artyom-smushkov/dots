import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire

ModuleBox {
    id: root
    color: "#74c7ec"
    clickable: true

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property int sinkPct: sink !== null && sink.audio !== null
        ? Math.round(sink.audio.volume * 100) : 0
    readonly property bool sinkMuted: sink !== null && sink.audio !== null && sink.audio.muted
    readonly property int sourcePct: source !== null && source.audio !== null
        ? Math.round(source.audio.volume * 100) : 0
    readonly property bool sourceMuted: source !== null && source.audio !== null && source.audio.muted

    readonly property var sinkIcons: ["\uF026", "\uF027", "\uF028"]

    function labelFor(sinkPct, sinkMuted, sourcePct, sourceMuted) {
        const sourcePart = sourceMuted ? "\uF131" : "\uF130 " + sourcePct + "%"
        if (sinkMuted) return "\uF6A9 " + sourcePart
        return sinkIcons[Math.min(2, Math.floor(sinkPct / 33))] + " " + sinkPct + "%" + " " + sourcePart
    }

    readonly property string label: labelFor(sinkPct, sinkMuted, sourcePct, sourceMuted)

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

    BarText {
        color: root.color
        text: root.label
    }
}
