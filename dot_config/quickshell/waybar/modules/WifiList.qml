import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ColumnLayout {
    id: root
    spacing: 0

    property var model: []
    property string busySsid: ""
    property string busyKind: ""
    property string failureSsid: ""
    property string failureReason: ""
    property color dimColor: "#a6adc8"

    signal rowClicked(string ssid)

    Flickable {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(260, listCol.implicitHeight)
        contentWidth: width
        contentHeight: listCol.height
        clip: true
        visible: model.count > 0

        Column {
            id: listCol
            width: parent.width
            Repeater {
                model: root.model
                delegate: NetworkRow {
                    width: parent.width
                    ssid: model.ssid
                    connected: model.connected
                    secured: model.secured
                    signalPct: model.signal
                    busy: root.busySsid !== "" && root.busySsid === model.ssid
                    busyKind: root.busySsid === model.ssid ? root.busyKind : ""
                    failure: root.failureSsid === model.ssid ? root.failureReason : ""
                    onClicked: root.rowClicked(model.ssid)
                }
            }
        }
    }

    BarText {
        visible: model.count === 0
        color: root.dimColor
        text: "No Wi-Fi networks"
    }
}
