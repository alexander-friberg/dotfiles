import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../style"
PanelWindow {
    id: root
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: 24
    exclusionMode: ExclusionMode.Auto
    focusable: false
    color: "transparent"
    IpcHandler {
        target: "bar"
        function toggle(): string { root.visible = !root.visible; return "visible=" + root.visible; }
        function show(): string { root.visible = true; return "visible=true"; }
        function hide(): string { root.visible = false; return "visible=false"; }
    }

    Item {
        id: barContent
        anchors.fill: parent
        height: 24
        clip: true


        Image {
            id: barBackground
            width: root.width
            height: root.height
            source: "../../style/assets/bar-material.png"
            opacity: 0.9
            z: -1
        }

        RowLayout {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Theme.spacing
            spacing: Theme.spacing
            Workspaces {}
            TrayModule {}
        }
        RowLayout {
            anchors.centerIn: parent
            ClockWidget {}
        }
        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: Theme.spacing
            spacing: Theme.spacing
            WifiHeart {}
            BatteryModule {}
        }
    }
}
