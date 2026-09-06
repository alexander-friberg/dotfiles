import QtQuick
import QtQuick.Layouts
import "../../style"

ColumnLayout {
    id: root
    property string label: ""
    property real value: 0
    property var history: []
    property real min: 0
    property real max: 100
    property color lineColor: Theme.fg
    property string imgPath: "../../assets/frames/SysFrame.png"

    Layout.preferredWidth: 60
    Layout.preferredHeight: 40
    spacing: 2

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        color: "transparent"
        clip: true

        Image {
            anchors.fill: parent
            source: root.imgPath
            visible: root.imgPath !== ""
            fillMode: Image.PreserveAspectCrop
            smooth: true
            mipmap: true
            asynchronous: true
            z: -1
                }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 4
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: root.label
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: 8
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: Math.round(root.value) + "%"
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: 8
                    font.bold: true
                }
            }

            Sparkline {
                Layout.fillWidth: true
                Layout.fillHeight: true
                values: root.history
                min: root.min
                max: root.max
                lineColor: root.lineColor
                thickness: 1
            }
        }
    }
}
