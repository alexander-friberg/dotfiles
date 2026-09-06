import QtQuick
import QtQuick.Layouts
import "../../style"
import "../../services"

Rectangle {
    id: root
    color: "transparent"
    implicitWidth: content.implicitWidth + 12
    implicitHeight: content.implicitHeight + 12


    Image {
        anchors.fill: parent
        source: "../../assets/frames/TermFrame.png"
        fillMode: Image.Stretch
        smooth: true
        mipmap: true
        asynchronous: true
        z: -1
    }

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 6
        spacing: 8

        Text {
            text: "[DCKR]"
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.bold: true
        }

        // Off-layout reference row purely to measure a single item's real
        // height. Deriving the cap from the ListView's own contentHeight
        // instead is circular: ListView virtualizes delegates based on its
        // own height, but that height would depend on contentHeight, which
        // depends on which delegates happen to be instantiated yet — in
        // practice that left the list showing a scrolled-looking window
        // instead of starting at the first item.
        DockerContainerRow {
            id: measureRow
            visible: false
            containerName: "measure"
        }

        ListView {
            id: containerList
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, 3 * measureRow.implicitHeight + 2 * spacing)
            clip: true
            spacing: 8
            visible: DockerService.containers.length > 0
            model: DockerService.containers
            delegate: DockerContainerRow {
                width: containerList.width
                containerId: modelData.id
                containerName: modelData.name
                statusColor: modelData.color
                exited: modelData.exited
                exitCode: modelData.exitCode
            }
        }

        Text {
            visible: DockerService.containers.length === 0
            text: "no containers"
            color: Theme.btDim
            font.family: Theme.fontFamily
            font.pixelSize: 10
        }
    }
}
