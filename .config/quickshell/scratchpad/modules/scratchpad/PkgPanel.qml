import QtQuick
import QtQuick.Layouts
import "../../style"
import "../../services"

// [PKG] dockapp: total update count with a big icon, then a per-source
// breakdown row — see scratchpad-pkg in scratchpad.yuck.
Rectangle {
    id: root
    implicitWidth: 178
    implicitHeight: 135
    color: Theme.bg
    border.color: Theme.border
    border.width: 1
    radius: 0

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 4

        Text {
            text: "[PKG]"
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: 17
            font.bold: true
        }

        RowLayout {
            Layout.bottomMargin: 8
            spacing: 12

            Text {
                text: ""
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 22
            }
            Text {
                text: PkgService.total
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 23
                font.bold: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.divider
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            PkgCell {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                label: "pacman"
                value: PkgService.pacman
            }
            PkgCell {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                label: "aur"
                value: PkgService.aur
            }
            PkgCell {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                label: "flatpak"
                value: PkgService.flatpak
            }
        }
    }
}
