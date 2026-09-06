import QtQuick
import "../../style"

// Replicates .scratchpad-scale's 10-segment striped look (eww paints this
// on top of a real GtkScale via CSS repeating-linear-gradient); here it's a
// small custom control since QML has no themeable native slider with that
// look built in. Drag or scroll to adjust; commits (debounced 300ms, like
// eww's :timeout "300ms") via the `moved` signal rather than on every
// pixel of movement.
Item {
    id: root

    property real value: 0
    property int trackWidth: 130
    property int trackHeight: 10
    property int handleHeight: 16
    property int segments: 10
    // How long after committing to keep ignoring external `value` updates —
    // needs to outlast the service's own poll interval, or a stale poll
    // tick landing before the real change is read back snaps the handle to
    // the old value and then forward again once the fresh poll arrives.
    property int settleTime: 2200

    signal moved(real newValue)

    implicitWidth: trackWidth
    implicitHeight: handleHeight

    property real _displayValue: value
    property bool _dragging: false
    property bool _settling: false

    onValueChanged: if (!_dragging && !_settling) _displayValue = value

    function _setFromX(x) {
        const frac = Math.max(0, Math.min(1, x / root.trackWidth));
        root._displayValue = Math.round(frac * 100);
        root._settling = true;
        commitTimer.restart();
    }

    Timer {
        id: commitTimer
        interval: 300
        onTriggered: {
            root.moved(root._displayValue);
            settleTimer.restart();
        }
    }

    Timer {
        id: settleTimer
        interval: root.settleTime
        onTriggered: root._settling = false
    }

    Rectangle {
        id: trough
        width: root.trackWidth
        height: root.trackHeight
        anchors.verticalCenter: parent.verticalCenter
        color: "#14ffffff"
        border.color: Theme.fg
        border.width: 1

        Row {
            anchors.fill: parent
            Repeater {
                model: root.segments
                delegate: Item {
                    width: trough.width / root.segments
                    height: trough.height
                    Rectangle {
                        anchors.right: parent.right
                        width: 1
                        height: parent.height
                        color: "#e6000000"
                        visible: index < root.segments - 1
                    }
                }
            }
        }
    }

    Item {
        anchors.left: trough.left
        anchors.verticalCenter: trough.verticalCenter
        width: trough.width * (root._displayValue / 100)
        height: trough.height
        clip: true

        Rectangle {
            width: trough.width
            height: trough.height
            color: Theme.fg

            Row {
                anchors.fill: parent
                Repeater {
                    model: root.segments
                    delegate: Item {
                        width: trough.width / root.segments
                        height: trough.height
                        Rectangle {
                            anchors.right: parent.right
                            width: 1
                            height: parent.height
                            color: "#e6000000"
                            visible: index < root.segments - 1
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        width: 8
        height: root.handleHeight
        color: Theme.fg
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(0, Math.min(root.trackWidth - width, trough.width * (root._displayValue / 100) - width / 2))
    }

    MouseArea {
        anchors.fill: parent
        onPressed: mouse => { root._dragging = true; root._setFromX(mouse.x); }
        onPositionChanged: mouse => { if (pressed) root._setFromX(mouse.x); }
        onReleased: root._dragging = false
        onWheel: wheel => {
            const delta = wheel.angleDelta.y > 0 ? 2 : -2;
            root._displayValue = Math.max(0, Math.min(100, root._displayValue + delta));
            root._settling = true;
            commitTimer.restart();
        }
    }
}
