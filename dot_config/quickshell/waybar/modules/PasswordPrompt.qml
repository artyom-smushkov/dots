import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

RowLayout {
    id: root
    spacing: 8
    visible: ssid !== ""

    property string ssid: ""
    property color fg: "#cdd6f4"
    property color dim: "#a6adc8"
    property color surface: "#313244"
    property color borderColor: "#45475a"

    signal submitted
    signal cancelled

    onSsidChanged: {
        if (ssid !== "") {
            field.clear()
            Qt.callLater(function() { field.forceActiveFocus() })
        }
    }

    BarText {
        color: root.fg
        text: root.ssid
        elide: Text.ElideMiddle
        Layout.preferredWidth: 120
    }

    TextField {
        id: field
        Layout.fillWidth: true
        echoMode: TextField.Password
        placeholderText: "Password"
        color: root.fg
        placeholderTextColor: root.dim
        font.family: "IosevkaTerm Nerd Font"
        font.pixelSize: 14
        background: Rectangle {
            color: root.surface
            border.color: root.borderColor
            border.width: 1
        }
        onAccepted: root.submitted()
        Keys.onEscapePressed: root.cancelled()
    }
}
