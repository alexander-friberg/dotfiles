import QtQuick
import "../../style"

Item {
    id: root
    property var device

    implicitHeight: 18
    implicitWidth: 110

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (device.paired) device.connect();
            else device.pair();
        }
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 5

        // Paired devices get a filled dot, discovered-but-unpaired ones a
        // hollow one — the "| " / "* " marks eww used didn't render at all
        // under Qt+JetBrainsMono Nerd Font here (a real, reproducible
        // font-shaping quirk verified via a static test string, not a
        // binding bug), so this replaces that distinction visually instead.
        Rectangle {
            width: 6
            height: 6
            anchors.verticalCenter: parent.verticalCenter
            radius: device.paired ? 0 : 3
            color: device.paired ? (mouse.containsMouse ? Theme.fg : Theme.btDim) : "transparent"
            border.width: device.paired ? 0 : 1
            border.color: mouse.containsMouse ? Theme.fg : Theme.btDim
        }

        Text {
            width: parent.width - 11
            text: device.name || device.deviceName
            color: mouse.containsMouse ? Theme.fg : Theme.btDim
            elide: Text.ElideRight
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }
    }

    // Once a previously-unpaired device finishes pairing, connect to it —
    // mirrors eww's `bluetoothctl pair && connect` chain for new devices.
    Connections {
        target: root.device
        function onPairedChanged() {
            if (root.device.paired && !root.device.connected) root.device.connect();
        }
    }
}
