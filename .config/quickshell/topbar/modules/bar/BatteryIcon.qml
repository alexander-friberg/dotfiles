import QtQuick
import "../../style"

Item {
    id: root
    property int percent: 0
    property bool charging: false

    readonly property int segmentCount: 5
    readonly property int segmentWidth: 3
    readonly property int segmentSpacing: 1
    readonly property int segmentHeight: 10
    readonly property int bodyBorderWidth: 1
    readonly property int bodyPadding: 1
    readonly property int bodyRadius: 2
    readonly property int terminalWidth: 2
    readonly property int terminalHeight: 6
    readonly property int terminalGap: 1

    readonly property int bodyContentWidth: segmentCount * segmentWidth + (segmentCount - 1) * segmentSpacing
    readonly property int bodyWidth: bodyContentWidth + 2 * (bodyBorderWidth + bodyPadding)
    readonly property int bodyHeight: segmentHeight + 2 * (bodyBorderWidth + bodyPadding)

    readonly property color fillColor: percent <= 10 ? Theme.critical : (percent <= 50 ? Theme.warning : Theme.accent)
    readonly property color emptyColor: Qt.rgba(1, 1, 1, 0.08)

    implicitWidth: bodyWidth + terminalGap + terminalWidth
    implicitHeight: Math.max(bodyHeight, terminalHeight)

    Rectangle {
        id: body
        width: root.bodyWidth
        height: root.bodyHeight
        anchors.verticalCenter: parent.verticalCenter
        radius: root.bodyRadius
        color: "transparent"
        border.color: Theme.border
        border.width: root.bodyBorderWidth

        Row {
            anchors.centerIn: parent
            spacing: root.segmentSpacing

            Repeater {
                model: root.segmentCount
                delegate: Rectangle {
                    width: root.segmentWidth
                    height: root.segmentHeight
                    radius: 1
                    color: root.percent > index * 20 ? root.fillColor : root.emptyColor
                }
            }
        }
    }

    Rectangle {
        id: terminal
        width: root.terminalWidth
        height: root.terminalHeight
        anchors.left: body.right
        anchors.leftMargin: root.terminalGap
        anchors.verticalCenter: parent.verticalCenter
        radius: 1
        color: "#ffffff"
    }

    // Nerd Font "bolt" glyph (fa-bolt, U+F0E7). If it doesn't render in
    // the configured font, swap this for "⚡" (unicode lightning bolt).
    readonly property string boltGlyph: ""

    Item {
        anchors.centerIn: body
        width: boltFill.implicitWidth
        height: boltFill.implicitHeight
        visible: root.charging

        Repeater {
            model: [Qt.point(-1, -1), Qt.point(0, -1), Qt.point(1, -1),
                    Qt.point(-1, 0), Qt.point(1, 0),
                    Qt.point(-1, 1), Qt.point(0, 1), Qt.point(1, 1)]
            delegate: Text {
                x: modelData.x
                y: modelData.y
                text: root.boltGlyph
                font.family: Theme.fontFamily
                font.pixelSize: 9
                color: "#000000"
            }
        }

        Text {
            id: boltFill
            text: root.boltGlyph
            font.family: Theme.fontFamily
            font.pixelSize: 9
            color: Theme.warning
        }
    }
}
