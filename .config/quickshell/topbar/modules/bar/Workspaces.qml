import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Hyprland
import "../../style"

RowLayout {
    id: root
    spacing: 4
    readonly property var sortedWorkspaces: {
        const values = Hyprland.workspaces.values.filter(ws => ws.id > 0);
        values.sort((a, b) => a.id - b.id);
        return values;
    }
    Repeater {
        model: root.sortedWorkspaces
        Item {
            id: wsIcon
            required property var modelData
            readonly property bool active: modelData.active
            readonly property bool urgent: modelData.urgent

            width: 16
            height: 16

            Image {
                id: icon
                anchors.fill: parent
                source: wsIcon.active
                    ? "../../style/assets/ActiveSpace.png"
                    : "../../style/assets/InactiveSpace.png"
                sourceSize: Qt.size(130, 130)
                opacity: 0
            }

            MultiEffect {
                anchors.fill: icon
                source: icon
                colorization: 1.0
                colorizationColor: wsIcon.urgent
                    ? Theme.critical
                    : (wsIcon.active ? Theme.accent2 : Theme.fg)
                brightness: 1.0
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + wsIcon.modelData.id)
            }
        }
    }
}
