import QtQuick
import Quickshell.Services.UPower
import ".."

Row {
    id: root
    spacing: 5
    visible: UPower.displayDevice.isPresent

    property var device: UPower.displayDevice
    property int pct: Math.round(device.percentage * 100)
    property bool charging: device.state === UPowerDeviceState.Charging
    property bool full: device.state === UPowerDeviceState.FullyCharged

    Item {
        width: 24
        height: 12
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            x: 22
            y: 3
            width: 2
            height: 6
            color: "black"
        }

        Rectangle {
            width: 22
            height: 12
            color: "transparent"
            border.width: 1
            border.color: "black"

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 2
                width: Math.max(0, Math.round((parent.width - 4) * root.pct / 100))
                color: "black"
            }
        }
    }

    Text {
        text: (root.charging ? "+" : "") + root.pct + "% |"
        color: "black"
        font.pixelSize: Config.settings.bar.fontSize
        font.family: fontMonaco.name
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignVCenter
    }
}
