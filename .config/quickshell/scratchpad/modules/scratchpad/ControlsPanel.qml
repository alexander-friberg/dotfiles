import QtQuick
import "../../style"
import "../../services"

// Brightness / night-mode warmth / volume — see scratchpad-controls in
// scratchpad.yuck. All three rows share the same 0-100 range; the
// night-mode row maps ControlsService's Kelvin state onto that range.
Rectangle {
    id: root
    implicitWidth: 178
    implicitHeight: 187
    color: Theme.bg
    border.color: Theme.border
    border.width: 1
    radius: 0

    Item {
        anchors.fill: parent
        anchors.margins: 6

        Column {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            spacing: 16

            ControlRow {
                icon: ""
                value: ControlsService.brightness
                onChanged: newValue => ControlsService.setBrightness(newValue)
            }

            ControlRow {
                icon: ""
                value: ControlsService.nightlightPercent
                iconActive: ControlsService.nightlightOn
                iconClickable: true
                onIconClicked: ControlsService.toggleNightlight()
                onChanged: newValue => ControlsService.setNightlightPercent(newValue)
            }

            ControlRow {
                icon: ControlsService.volumeMuted ? "" : ""
                value: ControlsService.volumePct
                onChanged: newValue => ControlsService.setVolume(newValue)
            }
        }
    }
}
