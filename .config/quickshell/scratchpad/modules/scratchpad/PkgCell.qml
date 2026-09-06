import QtQuick
import QtQuick.Layouts
import "../../style"

ColumnLayout {
    id: root
    property string label: ""
    property int value: 0

    spacing: 0

    Text {
        Layout.alignment: Qt.AlignHCenter
        text: root.label
        color: Theme.dim
        font.family: Theme.fontFamily
        font.pixelSize: 10
    }
    Text {
        Layout.alignment: Qt.AlignHCenter
        text: root.value
        color: Theme.dimmer
        font.family: Theme.fontFamily
        font.pixelSize: 10
        font.bold: true
    }
}
