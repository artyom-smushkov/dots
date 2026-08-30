import QtQuick
import Quickshell.Hyprland
import Quickshell.Io

ModuleBox {
    id: root
    color: "#a6e3a1"
    visible: loaded
    clickable: true

    property bool loaded: false
    property string label: ""
    property string keyboardName: ""

    readonly property string ipcScript: "use IO::Socket::UNIX;my $s=IO::Socket::UNIX->new(Peer=>$ARGV[0],Type=>SOCK_STREAM) or exit 1;$s->autoflush(1);print $s $ARGV[1];my $r=do{local $/;<$s>};print $r // \"\""

    function displayFor(name) {
        switch (name) {
        case "en":
        case "us": return "us"
        case "ru": return "ru"
        case "uk":
        case "ua": return "ua"
        default: return name
        }
    }

    function onSample(text) {
        let doc
        try { doc = JSON.parse(text) } catch (e) { return }
        const kbs = doc.keyboards
        if (!Array.isArray(kbs) || kbs.length === 0) return
        let kb = kbs[0]
        for (const k of kbs) if (k.main === true) { kb = k; break }
        const list = String(kb.layout || "").split(",").filter(function (s) { return s.length > 0 })
        const idx = kb.active_layout_index
        if (typeof idx !== "number" || idx < 0 || idx >= list.length) return
        const name = list[idx]
        if (typeof name !== "string" || name.length === 0) return
        keyboardName = String(kb.name || "")
        label = displayFor(name)
        loaded = true
    }

    Process {
        id: proc
        command: ["perl", "-e", root.ipcScript, Hyprland.requestSocketPath, "j/devices"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.onSample(text)
        }
    }

    Process {
        id: switchProc
        command: ["perl", "-e", root.ipcScript, Hyprland.requestSocketPath, "switchxkblayout " + root.keyboardName + " next"]
    }

    onClicked: {
        if (root.keyboardName !== "") switchProc.running = true
    }

    Item {
        Connections {
            target: Hyprland
            function onRawEvent(event) {
                if (event.name === "activelayout") proc.running = true
            }
        }

        Timer {
            id: pollTimer
            interval: 30000
            repeat: true
            onTriggered: proc.running = true
        }
    }

    Component.onCompleted: {
        proc.running = true
        pollTimer.start()
    }

    BarText {
        color: root.color
        text: "\u{F097B}  " + root.label
    }
}
