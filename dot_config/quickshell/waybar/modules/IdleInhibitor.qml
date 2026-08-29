import QtQuick
import Quickshell
import Quickshell.Wayland._IdleInhibitor

ModuleBox {
    id: root
    color: "#cda6f7"
    clickable: true
    tooltipText: activated ? "activated" : "deactivated"

    property bool activated: false

    readonly property string label: activated ? "\uF06E " : "\uF070 "

    Item {
        IdleInhibitor {
            id: inhibitor
            window: QsWindow.window
            enabled: root.activated
        }
    }

    onClicked: root.activated = !root.activated

    BarText {
        color: root.color
        text: root.label
    }
}
