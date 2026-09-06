import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../style"

PopupWindow {
    id: root

    property Item anchorItem: null
    property var trayItem: null
    property bool opened: false
    signal dismissed()

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    anchor.adjustment: PopupAdjustment.Slide

    visible: opened
    color: "transparent"
    implicitWidth: 180
    implicitHeight: frame.implicitHeight

    QsMenuOpener {
        id: opener
        menu: root.trayItem ? root.trayItem.menu : null
    }

    HyprlandFocusGrab {
        id: grab
        windows: [root]
        active: root.opened
        onCleared: root.dismissed()
    }

    Rectangle {
        id: frame
        anchors.fill: parent
        color: Theme.bg
        border.color: Theme.border
        border.width: 1
        implicitHeight: column.implicitHeight + 12

        ColumnLayout {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 6
            spacing: 2

            Repeater {
                model: opener.children

                delegate: Loader {
                    required property var modelData
                    Layout.fillWidth: true
                    sourceComponent: modelData.isSeparator ? sepComp : rowComp

                    Component {
                        id: sepComp
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.topMargin: 4
                            Layout.bottomMargin: 4
                            implicitHeight: 1
                            color: Theme.border
                            opacity: 0.3
                        }
                    }

                    Component {
                        id: rowComp
                        MenuRow { entry: modelData }
                    }
                }
            }
        }
    }

    component MenuRow: Rectangle {
        id: menuRow
        required property var entry
        Layout.fillWidth: true
        implicitHeight: label.implicitHeight + 10
        color: hover.hovered && entry.enabled ? Qt.rgba(1, 1, 1, 0.08) : "transparent"

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            text: (menuRow.entry.buttonType !== 0 && menuRow.entry.checkState === Qt.Checked ? "✓ " : "") + menuRow.entry.text
            color: Theme.fg
            opacity: menuRow.entry.enabled ? 1.0 : 0.4
            font.family: Theme.fontFamily
            font.pixelSize: 12
        }

        HoverHandler { id: hover }

        TapHandler {
            enabled: menuRow.entry.enabled
            onTapped: {
                menuRow.entry.triggered()
                root.dismissed()
            }
        }
    }
}
