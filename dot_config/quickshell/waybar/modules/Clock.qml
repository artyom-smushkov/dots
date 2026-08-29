import QtQuick

ModuleBox {
    id: root
    color: "#f9e2af"

    property var now: new Date()

    BarText {
        color: root.color
        text: "\uF017  " + String(now.getHours()).padStart(2, "0") + ":" + String(now.getMinutes()).padStart(2, "0")
    }

    Item {
        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: now = new Date()
        }
    }
}
