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
    readonly property int tooltipGap: 4
    readonly property var tooltipModule: cpuModule.tooltipVisible ? cpuModule
        : memModule.tooltipVisible ? memModule
        : diskModule.tooltipVisible ? diskModule
        : idleModule.tooltipVisible ? idleModule
        : null
    readonly property var tooltipPos: root.tooltipModule
        ? root.tooltipModule.mapToItem(root.contentItem, 0, 0) : Qt.point(0, 0)
    exclusiveZone: barHeight
    implicitHeight: barHeight

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

    PopupWindow {
        id: tooltipWindow
        visible: root.tooltipModule !== null
        color: "transparent"
        implicitWidth: tooltipLabel.implicitWidth + 2 * (tooltipBg.border.width + 8)
        implicitHeight: tooltipLabel.implicitHeight + 2 * (tooltipBg.border.width + 4)

        anchor {
            window: root
            rect.x: root.tooltipModule
                ? tooltipPos.x + root.tooltipModule.width / 2 - tooltipWindow.width / 2 : 0
            rect.y: root.tooltipModule
                ? tooltipPos.y + root.tooltipModule.height + root.tooltipGap : 0
        }

        Rectangle {
            id: tooltipBg
            anchors.fill: parent
            color: Qt.rgba(30/255, 30/255, 46/255, 0.9)
            border.color: "#74c7ec"
            border.width: 1
        }

        BarText {
            id: tooltipLabel
            anchors.centerIn: parent
            color: "#cdd6f4"
            text: root.tooltipModule ? root.tooltipModule.tooltipText : ""
        }
    }
}
