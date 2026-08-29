import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "modules"

PanelWindow {
    id: root
    WlrLayershell.layer: WlrLayer.Top
    anchors { top: true; left: true; right: true }
    color: "transparent"

    readonly property int barHeight: Math.max(bar.implicitHeight, centerSection.implicitHeight)
    readonly property int maxTooltipHeight: Math.max(cpuModule.tooltipHeight, memModule.tooltipHeight,
                       diskModule.tooltipHeight, idleModule.tooltipHeight)
    exclusiveZone: barHeight
    implicitHeight: barHeight + maxTooltipHeight

    RowLayout {
        id: bar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        RowLayout {
            id: leftSection
            spacing: 0

            Mpris {}
        }

        Item { Layout.fillWidth: true }

        RowLayout {
            id: rightSection
            spacing: 0

            Language {}
            Clock {}
            DateBox {}
            IdleInhibitor { id: idleModule }
            Notification {}
            Battery {}
        }
    }

    RowLayout {
        id: centerSection
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 0

        Network {}
        PulseAudio {}
        Cpu { id: cpuModule }
        Workspaces {}
        Memory { id: memModule }
        Disk { id: diskModule }
    }
}
