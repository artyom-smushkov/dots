import QtQuick
import Quickshell.Services.UPower

ModuleBox {
    id: root
    color: "#eba0ac"

    readonly property var device: UPower.displayDevice
    visible: device !== null && device.isLaptopBattery && device.isPresent

    readonly property int percentage: device ? Math.round(device.percentage * 100) : 0
    readonly property int state: device ? device.state : UPowerDeviceState.Unknown
    readonly property bool onBattery: UPower.onBattery

    function iconFor(state, onBattery, percentage) {
        if (state === UPowerDeviceState.Charging)
            return "\u{F0084}"
        if (!onBattery)
            return "\u{F1616}"
        const tiers = ["\u{F007A}", "\u{F007B}", "\u{F007C}", "\u{F007D}", "\u{F007E}",
                       "\u{F007F}", "\u{F0080}", "\u{F0081}", "\u{F0082}", "\u{F0079}"]
        return tiers[Math.min(9, Math.floor(percentage / 10))]
    }

    BarText {
        color: root.color
        text: root.iconFor(root.state, root.onBattery, root.percentage) + " " + root.percentage + "%"
    }
}
