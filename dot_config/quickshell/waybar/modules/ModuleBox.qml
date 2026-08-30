import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    property color color: "#a6e3a1"
    property bool leftMargin16: false
    property string tooltipText: ""
    property bool clickable: false
    property bool wheelable: false
    property bool middleClickable: false

    signal clicked
    signal wheelUp(real x)
    signal wheelDown(real x)
    signal middleClicked(real x)

    readonly property bool tooltipVisible: tooltipText !== "" && hoverArea.containsMouse

    readonly property int borderWidth: 2
    property int paddingH: 10
    property int paddingV: 4

    Layout.topMargin: 16
    Layout.rightMargin: 16
    Layout.leftMargin: leftMargin16 ? 16 : 0
    Layout.bottomMargin: 0

    implicitWidth: content.implicitWidth + 2 * (borderWidth + paddingH)
    implicitHeight: content.implicitHeight + 2 * (borderWidth + paddingV)

    default property alias data: row.data

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(30/255, 30/255, 46/255, 0.9)
        border.color: "#45475a"
        border.width: 2
    }

    Control {
        id: content
        anchors.fill: parent
        anchors.leftMargin: borderWidth + paddingH
        anchors.rightMargin: borderWidth + paddingH
        anchors.topMargin: borderWidth + paddingV
        anchors.bottomMargin: borderWidth + paddingV
        background: null
        padding: 0
        implicitWidth: row.implicitWidth
        implicitHeight: row.implicitHeight

        RowLayout {
            id: row
            anchors.fill: parent
            spacing: 0
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: root.tooltipText !== ""
        enabled: root.tooltipText !== "" || root.clickable || root.middleClickable
        acceptedButtons: Qt.AllButtons
        onClicked: { if (root.clickable && mouse.button === Qt.LeftButton) root.clicked() }
        onPressed: { if (root.middleClickable && mouse.button === Qt.MiddleButton) root.middleClicked(mouse.x) }
        onWheel: {
            if (root.wheelable) {
                if (wheel.angleDelta.y > 0) root.wheelUp(wheel.x)
                else if (wheel.angleDelta.y < 0) root.wheelDown(wheel.x)
            }
        }
    }

}
