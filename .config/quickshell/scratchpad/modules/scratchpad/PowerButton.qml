import QtQuick
import "../../style"

// One-shot action button (sleep/exit) — see scratchpad-btn in
// scratchpad.yuck.
Rectangle {
    id: root
    property string icon: ""

    signal clicked()

    implicitWidth: 85
    implicitHeight: 90
    color: Theme.bg
    border.width: 1
    border.color: Theme.border
    radius: 0

    property bool _cooldown: false

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: Theme.fg
        font.family: Theme.fontFamily
        font.pixelSize: 28
    }

    Timer { id: cooldownTimer; interval: 500; onTriggered: root._cooldown = false }

    MouseArea {
        anchors.fill: parent
        enabled: !root._cooldown
        onClicked: {
            root._cooldown = true;
            cooldownTimer.restart();
            root.clicked();
        }
    }
}
