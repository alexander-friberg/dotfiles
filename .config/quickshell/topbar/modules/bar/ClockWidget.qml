import QtQuick
import "../../style"

Item {
    id: root
    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    property date now: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    Text {
        id: label
        text: "" + Qt.formatDateTime(root.now, "hh:mm") + ""
        color: Theme.fg
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: tooltip.visible = true
        onExited: tooltip.visible = false
    }

    Rectangle {
        id: tooltip
        visible: false
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 4
        color: "#000000"
        border.color: Theme.border
        border.width: 1
        width: tooltipLabel.implicitWidth + 12
        height: tooltipLabel.implicitHeight + 8
        z: 100

        Text {
            id: tooltipLabel
            anchors.centerIn: parent
            text: "[" + Qt.formatDateTime(root.now, "dddd, dd MMMM yyyy") + "]"
            color: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: 12
        }
    }
}
