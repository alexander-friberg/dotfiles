import QtQuick
import "../../style"

// Click-to-arm button (reboot/shutdown) — see scratchpad-confirm-btn in
// scratchpad.yuck. First click arms (red border, warning glyph, ~3s
// window); a second click while armed fires `confirmed()`. Unlike eww,
// which arms via a defvar and reverts through a detached sleep-then-revert
// script, the arm timeout is just a QML Timer here — no external process
// needed since this component already owns the state.
Rectangle {
    id: root
    property string icon: ""
    property int revertMs: 3000

    signal confirmed()

    implicitWidth: 85
    implicitHeight: 90
    color: Theme.bg
    border.width: 1
    border.color: root._armed ? Theme.armedRed : Theme.border
    radius: 0

    property bool _armed: false
    property bool _cooldown: false

    Text {
        anchors.centerIn: parent
        text: root._armed ? "" : root.icon
        color: root._armed ? Theme.armedRed : Theme.fg
        font.family: Theme.fontFamily
        font.pixelSize: 28
    }

    Timer { id: revertTimer; interval: root.revertMs; onTriggered: root._armed = false }
    Timer { id: cooldownTimer; interval: 500; onTriggered: root._cooldown = false }

    MouseArea {
        anchors.fill: parent
        enabled: !root._cooldown
        onClicked: {
            root._cooldown = true;
            cooldownTimer.restart();
            if (root._armed) {
                root._armed = false;
                revertTimer.stop();
                root.confirmed();
            } else {
                root._armed = true;
                revertTimer.restart();
            }
        }
    }
}
