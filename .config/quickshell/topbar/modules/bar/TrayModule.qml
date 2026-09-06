import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import "../../style"

RowLayout {
    id: root
    spacing: 8

    Repeater {
        model: SystemTray.items

        Item {
            id: trayIcon
            required property var modelData
            property bool opened: false
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16

            Image {
                anchors.fill: parent
                sourceSize.width: 16
                sourceSize.height: 16
                source: trayIcon.modelData.icon
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) {
                        trayIcon.modelData.activate();
                    } else if (trayIcon.modelData.hasMenu) {
                        trayIcon.opened = !trayIcon.opened;
                    } else {
                        trayIcon.modelData.secondaryActivate();
                    }
                }
            }

            TrayMenu {
                anchorItem: trayIcon
                trayItem: trayIcon.modelData
                opened: trayIcon.opened
                onDismissed: trayIcon.opened = false
            }
        }
    }
}
