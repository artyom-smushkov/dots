import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

ModuleBox {
    id: root
    paddingH: 1
    paddingV: 0

    Repeater {
        model: Hyprland.workspaces
        delegate: Rectangle {
            id: cell
            property var ws: modelData
            readonly property bool isActive: ws !== null && ws.active
            readonly property bool isHover: hoverArea.containsMouse
            readonly property bool highlight: isActive || isHover

            Layout.leftMargin: 3
            Layout.rightMargin: 3
            Layout.topMargin: 4
            Layout.bottomMargin: 4
            Layout.preferredWidth: Math.max(isActive ? 25 : 7, label.implicitWidth + 10)
            Layout.preferredHeight: label.implicitHeight
            color: highlight ? "#74c7ec" : Qt.rgba(88/255, 91/255, 112/255, 0.5)

            Behavior on color { ColorAnimation { duration: 100 } }
            Behavior on width { NumberAnimation { duration: 100 } }

            BarText {
                id: label
                anchors.centerIn: parent
                text: " "
                color: highlight ? "#313244" : Qt.rgba(88/255, 91/255, 112/255, 0.5)
            }

            MouseArea {
                id: hoverArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Hyprland.dispatch("hl.dsp.focus({workspace=" + ws.id + "})")
                onWheel: {
                    var cur = Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
                    if (wheel.angleDelta.y > 0 && cur > 1) {
                        Hyprland.dispatch("hl.dsp.focus({workspace=" + (cur - 1) + "})")
                    } else if (wheel.angleDelta.y < 0) {
                        Hyprland.dispatch("hl.dsp.focus({workspace=" + (cur + 1) + "})")
                    }
                }
            }
        }
    }
}
