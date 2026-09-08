import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PanelWindow {
    id: root
    anchors {
        top: true
        right: true
        bottom: true
    }
    // Layer-shell surfaces only get a buffer sized to implicitWidth —
    // content anchored past that (e.g. DockerPanel, wider than the other
    // panels) gets clipped at the surface edge, not just hidden behind
    // something, so this has to track the widest child rather than a
    // fixed guess.
    property real leftPad: 20
    implicitWidth: contentColumn.implicitWidth + 24 + leftPad
    exclusionMode: ExclusionMode.Auto
    focusable: false
    color: "transparent"

    IpcHandler {
        target: "sidebar"
        function toggle(): string { root.visible = !root.visible; return "visible=" + root.visible; }
        function show(): string { root.visible = true; return "visible=true"; }
        function hide(): string { root.visible = false; return "visible=false"; }
    }
    Image {
        anchors.fill: parent
        source: "../../assets/scrollbar.jpg"
        fillMode: Image.Stretch
        opacity: 1
        smooth: true
        mipmap: true
        asynchronous: true
        z: -1
    }

    ColumnLayout {
        id: contentColumn
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 12
        spacing: 10

        SysStatsPanel {}
        Title {input: "NERVE // TERM::STAT"}
        BluetoothPanel { Layout.fillWidth: true }
        DockerPanel { Layout.fillWidth: true }
    }
}
