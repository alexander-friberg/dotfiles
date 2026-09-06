import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import Quickshell.Hyprland
import "../../style"
import "BatteryModel.js" as Model

PopupWindow {
    id: root

    property Item anchorItem: null
    property var device: null
    property bool opened: false
    signal dismissed()

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom | Edges.Right
    anchor.gravity: Edges.Bottom | Edges.Left
    anchor.adjustment: PopupAdjustment.Slide

    visible: opened
    color: "transparent"
    implicitWidth: 280
    implicitHeight: frame.implicitHeight

    readonly property bool onBattery: UPower.onBattery
    readonly property bool present: !!(device && device.isPresent)
    readonly property int percent: present ? Math.round(device.percentage * 100) : 0
    readonly property real fraction: Model.batteryFraction(device)

    readonly property var upowerStates: ({
        Charging: UPowerDeviceState.Charging,
        Discharging: UPowerDeviceState.Discharging,
        FullyCharged: UPowerDeviceState.FullyCharged,
        PendingCharge: UPowerDeviceState.PendingCharge
    })
    readonly property var profileStates: ({
        PowerSaver: PowerProfile.PowerSaver,
        Balanced: PowerProfile.Balanced,
        Performance: PowerProfile.Performance
    })

    readonly property bool thresholdActive: Model.chargeThresholdActive(device, onBattery, upowerStates)
    readonly property string statusText: Model.modeLabel(device, onBattery, upowerStates)

    readonly property var availableProfiles: {
        var list = [PowerProfile.PowerSaver, PowerProfile.Balanced]
        if (PowerProfiles.hasPerformanceProfile) list.push(PowerProfile.Performance)
        return list
    }

    property string cycleCount: "—"

    // UPower.displayDevice is a synthetic aggregate with no nativePath, so the
    // real per-device path (needed for `upower -i`, which is the only way to
    // get charge-cycles — Quickshell doesn't expose it as a typed property)
    // has to come from the actual laptop battery entry in UPower.devices.
    readonly property var batteryDevice: {
        var list = UPower.devices ? UPower.devices.values : []
        for (var i = 0; i < list.length; i++) {
            if (list[i] && list[i].isLaptopBattery) return list[i]
        }
        return null
    }

    Process {
        id: cyclesProc
        command: root.batteryDevice ? ["upower", "-i", "/org/freedesktop/UPower/devices/battery_" + root.batteryDevice.nativePath] : []
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var m = text.match(/charge-cycles:\s*(\d+)/)
                root.cycleCount = m ? m[1] : "—"
            }
        }
    }

    onOpenedChanged: if (opened && batteryDevice) cyclesProc.running = true

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
        implicitHeight: column.implicitHeight + 24

        ColumnLayout {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 12
            spacing: 10

            // ---------- Hero: title/status · percentage ----------
            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 2

                    Text {
                        text: "[BATTERY]"
                        color: Theme.fg
                        font.bold: true
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                    }

                    Text {
                        text: root.statusText.toUpperCase()
                        color: Theme.fg
                        opacity: 0.6
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: root.present ? (root.percent + "%") : "—"
                    color: root.percent < 15 ? Theme.critical : (root.percent < 30 ? Theme.warning : Theme.fg)
                    font.bold: true
                    font.family: Theme.fontFamily
                    font.pixelSize: 20
                }
            }

            // ---------- Progress bar ----------
            Item {
                Layout.fillWidth: true
                implicitHeight: 6

                Rectangle {
                    id: track
                    anchors.fill: parent
                    radius: height / 2
                    color: Qt.rgba(1, 1, 1, 0.12)
                }

                Rectangle {
                    id: fill
                    anchors.left: track.left
                    anchors.verticalCenter: track.verticalCenter
                    height: track.height
                    radius: track.radius
                    color: root.thresholdActive ? Theme.warning : (root.percent < 15 ? Theme.critical : Theme.accent)
                    width: Math.max(height, track.width * root.fraction)

                    Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

                    SequentialAnimation on opacity {
                        running: root.opened && !root.onBattery && !root.thresholdActive && root.fraction < 1
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 0.55; duration: 900; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 0.55; to: 1.0; duration: 900; easing.type: Easing.InOutSine }
                    }
                }
            }

            // ---------- Stats ----------
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 8
                columnSpacing: 20

                InfoCell {
                    label: "Size"
                    value: root.present ? Model.formatWh(root.device.energyCapacity) : "—"
                }
                InfoCell {
                    label: root.thresholdActive ? "Holding" : (root.onBattery ? "Time left" : "Time to full")
                    value: root.present
                        ? (root.thresholdActive
                            ? "—"
                            : Model.formatDuration(root.onBattery ? root.device.timeToEmpty : root.device.timeToFull))
                        : "—"
                }
                InfoCell {
                    label: "Cycles"
                    value: root.cycleCount
                }
                InfoCell {
                    label: "Rate"
                    value: root.present ? Model.formatRate(root.device.changeRate) : "—"
                }
            }

            // ---------- Power profile picker ----------
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: root.availableProfiles

                    delegate: Rectangle {
                        id: profileButton
                        required property var modelData

                        readonly property bool active: modelData === PowerProfiles.profile

                        Layout.fillWidth: true
                        implicitHeight: profileCol.implicitHeight + 12
                        color: active ? Theme.fg : "transparent"
                        border.color: Theme.fg
                        border.width: 1

                        ColumnLayout {
                            id: profileCol
                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: Model.profileIcon(profileButton.modelData, root.profileStates)
                                color: profileButton.active ? Theme.bg : Theme.fg
                                font.family: Theme.fontFamily
                                font.pixelSize: 16
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: Model.profileLabel(profileButton.modelData, root.profileStates)
                                color: profileButton.active ? Theme.bg : Theme.fg
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: PowerProfiles.profile = profileButton.modelData
                        }
                    }
                }
            }
        }
    }

    component InfoCell: ColumnLayout {
        id: cell
        property string label: ""
        property string value: ""
        spacing: 2

        Text {
            text: cell.label
            color: Theme.fg
            opacity: 0.6
            font.family: Theme.fontFamily
            font.pixelSize: 10
        }

        Text {
            text: cell.value
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.bold: true
        }
    }
}
