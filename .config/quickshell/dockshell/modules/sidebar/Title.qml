import QtQuick
import QtQuick.Layouts
import "../../style/"

Item {
    id: root
    Layout.fillWidth: true
    height: label.implicitHeight + 8
    opacity: 0.6
    property string input: ""

    Rectangle { // top border
        anchors.top: parent.top
        width: parent.width
        height: 1
        color: Theme.fg
    }

    Text {
        id: label
        anchors.centerIn: parent
        width: parent.width
        text: root.input
        font.family: Theme.fontFamily
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: Theme.fg
    }

    Rectangle { // bottom border
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Theme.fg
    }
}
