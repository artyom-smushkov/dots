import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property string ssid: ""
    property bool connected: false
    property bool secured: false
    property int signalPct: 0
    property bool busy: false
    property string busyKind: ""
    property string failure: ""

    signal clicked(string ssid)

    readonly property string icon: utils.signalIcon(signalPct)

    implicitHeight: 30
    height: implicitHeight

    Rectangle {
        anchors.fill: parent
        color: hoverArea.containsMouse ? "#313244" : "transparent"
        border.color: root.connected ? "#a6e3a1" : "transparent"
        border.width: root.connected ? 1 : 0
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 8

        BarText {
            color: root.connected ? "#a6e3a1" : "#cdd6f4"
            text: root.icon
        }

        BarText {
            Layout.fillWidth: true
            color: root.connected ? "#a6e3a1" : "#cdd6f4"
            text: root.ssid
            elide: Text.ElideRight
        }

        BarText {
            visible: root.secured
            color: "#a6adc8"
            text: "\uF06C"
        }

        BarText {
            visible: root.busy
            color: "#89b4fa"
            text: root.busyKind === "disconnect" ? "Disconnecting…" : "Connecting…"
        }

        BarText {
            visible: root.failure !== ""
            color: "#f38ba8"
            text: root.failure
            elide: Text.ElideRight
        }

        BarText {
            visible: root.connected
            color: "#a6e3a1"
            text: "\uF12C"
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked(root.ssid)
    }

    NetUtils {
        id: utils
    }
}
