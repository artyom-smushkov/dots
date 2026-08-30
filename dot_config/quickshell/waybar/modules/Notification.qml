import QtQuick
import Quickshell.Io

ModuleBox {
    id: root
    color: "#b4befe"
    clickable: true

    property string state: ""
    property bool loaded: false

    readonly property bool hasNotification: state.endsWith("notification")
    readonly property bool dnd: state.startsWith("dnd")
    readonly property string bell: dnd ? "\uF1F6" : "\uF0F3"
    readonly property string label: bell + (hasNotification ? "\uF444" : "")

    visible: loaded

    function onLine(line) {
        line = line.trim()
        if (line === "") return
        let json
        try { json = JSON.parse(line) } catch (e) { return }
        if (typeof json.alt !== "string") return
        root.state = json.alt
        root.loaded = true
    }

    Item {
        Process {
            id: proc
            command: ["swaync-client", "-swb"]
            running: true
            stdout: SplitParser {
                splitMarker: "\n"
                onRead: (line) => root.onLine(line)
            }
        }
        Process {
            id: toggleProc
            command: ["sh", "-c", "~/.local/bin/task-waybar &"]
        }
    }

    onClicked: toggleProc.running = true

    Item {
        id: labelItem
        implicitWidth: bellText.implicitWidth
        implicitHeight: bellText.implicitHeight

        BarText {
            id: bellText
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            color: root.color
            text: root.bell
        }

        BarText {
            id: dot
            visible: root.hasNotification
            anchors.top: bellText.top
            anchors.topMargin: -4
            anchors.left: bellText.right
            anchors.leftMargin: -4
            color: "red"
            text: "\uF444"
        }
    }
}
