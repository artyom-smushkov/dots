import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    property var node: null
    property string kind: ""
    property bool isDefault: false
    property string fg: "#cdd6f4"
    property string fgDim: "#a6adc8"
    property string accent: "#74c7ec"
    property string boost: "#f38ba8"

    signal defaultRequested

    readonly property bool isInput: kind === "source" || kind === "recording"
    readonly property bool isDevice: kind === "sink" || kind === "source"
    readonly property bool ready: node !== null && node.ready && node.audio !== null
    readonly property real vol: ready ? node.audio.volume : 0
    readonly property int pct: ready ? Math.round(vol * 100) : 0
    readonly property bool over: pct > 100
    readonly property bool muted: ready && node.audio.muted
    readonly property string displayName: node !== null && node.description !== ""
        ? node.description : (node !== null ? node.name : "")

    implicitHeight: row.implicitHeight

    function kindIconFor(k) {
        if (k === "sink") return "\uF028"
        if (k === "source") return "\uF130"
        if (k === "playback") return "\uF001"
        if (k === "recording") return "\uF130"
        return ""
    }
    readonly property string kindIcon: kindIconFor(kind)

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        spacing: 8

        BarText {
            color: root.fgDim
            text: root.kindIcon
            Layout.alignment: Qt.AlignVCenter
        }

        BarText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            color: root.isDefault ? root.accent : (root.ready ? root.fg : root.fgDim)
            text: root.displayName
            elide: Text.ElideRight
        }

        Item {
            width: 18
            height: 18
            BarText {
                anchors.centerIn: parent
                color: root.muted ? root.boost : root.fgDim
                text: root.isInput
                    ? (root.muted ? "\uF131" : "\uF130")
                    : (root.muted ? "\u{F075F}" : "\uF028")
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                enabled: root.ready
                onClicked: { if (node.audio) node.audio.muted = !node.audio.muted }
            }
        }

        Item {
            id: slider
            Layout.alignment: Qt.AlignVCenter
            width: 110
            height: 16

            readonly property real ratio: 1.0 / 1.5
            readonly property real snapPx: 5
            readonly property real handleX:
                Math.min(1, Math.max(0, root.vol / 1.5)) * width

            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: 4
                radius: 2
                color: Qt.rgba(1, 1, 1, 0.12)
            }
            Rectangle {
                x: 0
                anchors.verticalCenter: parent.verticalCenter
                height: 4
                radius: 2
                width: Math.min(slider.handleX, slider.ratio * slider.width)
                color: root.muted ? Qt.rgba(1, 1, 1, 0.2) : root.accent
            }
            Rectangle {
                x: slider.ratio * slider.width
                anchors.verticalCenter: parent.verticalCenter
                height: 4
                radius: 2
                width: Math.max(0, slider.handleX - slider.ratio * slider.width)
                visible: root.over && !root.muted
                color: root.boost
            }
            Rectangle {
                x: slider.ratio * slider.width - 1
                y: 0
                width: 2
                height: 14
                color: Qt.rgba(1, 1, 1, 0.6)
            }
            Rectangle {
                x: slider.handleX - 5
                y: slider.height / 2 - 5
                width: 10
                height: 10
                radius: 5
                color: root.over ? root.boost : (root.pct === 100 ? root.accent : root.fg)
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                enabled: root.ready
                property real dragX: 0
                function apply() {
                    if (!node || !node.audio) return
                    var v = dragX / slider.width * 1.5
                    if (Math.abs(dragX - slider.ratio * slider.width) <= slider.snapPx)
                        v = 1.0
                    v = Math.max(0, Math.min(1.5, v))
                    node.audio.volume = Math.round(v * 100) / 100
                }
                onPressed: function(mouse) { dragX = mouse.x; apply() }
                onPositionChanged: function(mouse) { if (pressed) { dragX = mouse.x; apply() } }
            }
        }

        Item {
            width: 40
            Layout.alignment: Qt.AlignVCenter
            BarText {
                anchors.fill: parent
                horizontalAlignment: Text.AlignRight
                color: root.over ? root.boost : root.fgDim
                text: root.pct + "%"
            }
        }

        Item {
            width: 18
            height: 18
            Layout.alignment: Qt.AlignVCenter
            BarText {
                anchors.centerIn: parent
                visible: root.isDevice
                color: root.isDefault ? root.accent : root.fgDim
                text: "\uF005"
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                enabled: root.isDevice
                onClicked: root.defaultRequested()
            }
        }
    }
}
