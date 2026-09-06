import QtQuick
import QtQuick.Layouts
import "../../style"
import "../../services"

Rectangle {
    id: root
    color: "transparent"
    implicitWidth: 130
    implicitHeight: content.implicitHeight + 12

    property var adapter: BluetoothService.adapter

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
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: "[BT]"
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                border.color: Theme.fg
                border.width: 1
                color: "transparent"
                implicitWidth: powerLabel.implicitWidth + 16
                implicitHeight: powerLabel.implicitHeight + 4

                Text {
                    id: powerLabel
                    anchors.centerIn: parent
                    text: root.adapter && root.adapter.enabled ? "ON" : "OFF"
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: BluetoothService.togglePower()
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6
            visible: root.adapter !== null && root.adapter.enabled

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                visible: BluetoothService.connectedDevices.length > 0

                Repeater {
                    model: BluetoothService.connectedDevices

                    delegate: Item {
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: Math.max(10, connectedLabel.implicitHeight)

                        MouseArea {
                            anchors.fill: parent
                            onClicked: modelData.disconnect()
                        }

                        Row {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 6

                            Rectangle {
                                width: 10
                                height: 10
                                anchors.verticalCenter: parent.verticalCenter
                                color: Theme.btConnectedDot
                            }

                            Text {
                                id: connectedLabel
                                width: parent.width - 16
                                text: modelData.name || modelData.deviceName
                                color: Theme.fg
                                elide: Text.ElideRight
                                font.family: Theme.fontFamily
                                font.pixelSize: 12
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.btDivider
                }
            }

            ListView {
                id: deviceList
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(contentHeight, 3 * 18 + 2 * spacing)
                clip: true
                spacing: 3
                model: BluetoothService.otherDevices
                delegate: BluetoothDeviceRow {
                    width: deviceList.width
                    device: modelData
                }
            }

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                border.color: Theme.btScanBorder
                border.width: 1
                color: "transparent"
                implicitWidth: scanLabel.implicitWidth + 16
                implicitHeight: scanLabel.implicitHeight + 4

                Text {
                    id: scanLabel
                    anchors.centerIn: parent
                    text: root.adapter && root.adapter.discovering
                          ? (BluetoothService.scanDots === 1 ? "." : BluetoothService.scanDots === 2 ? ".." : "...")
                          : "SCAN"
                    color: Theme.btScanBorder
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: BluetoothService.toggleScan()
                }
            }
        }
    }
}
