import QtQuick
import QtQuick.Layouts
import "../../style"
import "../../services"

ColumnLayout {
    id: root
    property string containerId: ""
    property string containerName: ""
    property color statusColor: Theme.dockerRunning
    property bool exited: false
    property int exitCode: 0

    Layout.fillWidth: true
    spacing: 3

    RowLayout {
        spacing: 4

        // All three action buttons share one uniform small white box,
        // regardless of each icon's own native SVG size/aspect ratio.
        Rectangle {
            implicitWidth: 16
            implicitHeight: 16
            border.color: Theme.border
            border.width: 1
            color: "transparent"

            Image {
                anchors.centerIn: parent
                width: 12
                height: 12
                fillMode: Image.PreserveAspectFit
                source: "../../assets/icons/StopIcon.svg"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: DockerService.stopContainer(root.containerId)
            }
        }

        Rectangle {
            implicitWidth: 16
            implicitHeight: 16
            border.color: Theme.border
            border.width: 1
            color: "transparent"

            Image {
                anchors.centerIn: parent
                width: 12
                height: 12
                fillMode: Image.PreserveAspectFit
                source: "../../assets/icons/RestartIcon.svg"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: DockerService.restartContainer(root.containerId)
            }
        }

        Rectangle {
            implicitWidth: 16
            implicitHeight: 16
            border.color: Theme.border
            border.width: 1
            color: "transparent"

            Image {
                anchors.centerIn: parent
                width: 12
                height: 12
                fillMode: Image.PreserveAspectFit
                source: "../../assets/icons/LogIcon.svg"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: DockerService.openLogs(root.containerId)
            }
        }
    }

    Row {
        Layout.fillWidth: true
        spacing: 5

        // Filled dot = normal state (color carries which one); hollow
        // dot = exited with a non-zero code, matching
        // BluetoothDeviceRow's filled/hollow paired-device convention.
        Rectangle {
            width: 6
            height: 6
            anchors.verticalCenter: parent.verticalCenter
            radius: root.exited ? 3 : 0
            color: root.exited ? Theme.dockerExited : Theme.dockerRunning
            border.width: root.exited ? 1 : 0
            border.color: Theme.dockerRunning
        }

        Text {
            width: parent.width - 11 - (root.exited ? exitCodeLabel.implicitWidth + 5 : 0)
            text: root.containerName
            color: Theme.fg
            elide: Text.ElideRight
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }

        Text {
            id: exitCodeLabel
            visible: root.exited
            text: "( " + root.exitCode + " )"
            color: Theme.dockerExited
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }
    }
}
