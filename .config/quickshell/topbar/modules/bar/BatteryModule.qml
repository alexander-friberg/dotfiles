import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "../../style"

Item {
    id: root
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    readonly property var device: UPower.displayDevice
    readonly property int percent: device ? Math.round(device.percentage * 100) : 0
    readonly property bool charging: device ? (device.state === UPowerDeviceState.Charging) : false
    property bool opened: false

    RowLayout {
        id: content
        spacing: Theme.spacing / 2

        BatteryIcon {
            Layout.alignment: Qt.AlignVCenter
            percent: root.percent
            charging: root.charging
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            text: root.percent + "%"
            color: root.percent < 15 ? Theme.critical : (root.percent < 30 ? Theme.warning : Theme.fg)
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.opened = !root.opened
    }

    BatteryPanel {
        anchorItem: root
        device: root.device
        opened: root.opened
        onDismissed: root.opened = false
    }
}
