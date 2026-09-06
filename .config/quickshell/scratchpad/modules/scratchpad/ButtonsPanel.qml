import QtQuick
import QtQuick.Layouts
import "../../style"
import "../../services"

// 2x2 power/mode grid — see scratchpad-buttons in scratchpad.yuck. Unlike
// the other panels, this one has no outer dockapp border/background: each
// button paints its own box, and the container is just a plain layout.
Item {
    id: root
    implicitWidth: 178
    implicitHeight: 187

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        RowLayout {
            spacing: 8
            PowerButton {
                icon: ""
                onClicked: PowerService.sleep()
            }
            PowerButton {
                icon: ""
                onClicked: PowerService.exit()
            }
        }
        RowLayout {
            spacing: 8
            ConfirmButton {
                icon: ""
                onConfirmed: PowerService.reboot()
            }
            ConfirmButton {
                icon: ""
                onConfirmed: PowerService.poweroff()
            }
        }
    }
}
