import QtQuick
import Quickshell.Io
import "../../style"
import "../../services"

Item {
    id: root
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Process {
        id: nmtuiProc
        command: ["kitty", "--class", "kitty-nmtui", "-e", "nmtui-go"]
    }

    Text {
        id: label
        text: WifiService.markupText
        textFormat: Text.RichText
        color: Theme.fg
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: nmtuiProc.running = true
        onEntered: tooltip.visible = true
        onExited: tooltip.visible = false
    }

    Rectangle {
        id: tooltip
        visible: false
        anchors.top: root.bottom
        anchors.right: root.right
        anchors.topMargin: 4
        color: "#000000"
        border.color: Theme.border
        border.width: 1
        width: tooltipLabel.implicitWidth + 12
        height: tooltipLabel.implicitHeight + 8
        z: 100

        Text {
            id: tooltipLabel
            anchors.centerIn: parent
            text: WifiService.tooltipText
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: 12
        }
    }
}
