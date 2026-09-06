import QtQuick
import QtQuick.Layouts
import "../../style"

RowLayout {
    id: root
    property string icon: ""
    property real value: 0
    property bool iconActive: false
    property bool iconClickable: false

    signal iconClicked()
    signal changed(real newValue)

    spacing: 6

    MouseArea {
        Layout.preferredWidth: 18
        Layout.preferredHeight: 18
        enabled: root.iconClickable
        cursorShape: root.iconClickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.iconClicked()

        Text {
            anchors.centerIn: parent
            text: root.icon
            color: root.iconActive ? Theme.accent2 : Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: 13
        }
    }

    SegmentedSlider {
        Layout.alignment: Qt.AlignVCenter
        value: root.value
        onMoved: newValue => root.changed(newValue)
    }
}
