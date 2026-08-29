import QtQuick

ModuleBox {
    id: root
    color: "#94e2d5"

    property var now: new Date()

    BarText {
        color: root.color
        text: "\uF073  " + String(now.getDate()).padStart(2, "0")
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
