import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "./modules/scratchpad"

// Final assembly — see scratchpad-widget in scratchpad.yuck. A fullscreen
// overlay (so the backdrop dim covers the whole screen, not just the
// dashboard's own footprint) with the actual dashboard centered inside via
// layout rather than window geometry. Starts hidden; toggled from
// hyprland.lua's SUPER+D bind via
// `qs -c scratchpad ipc call -- scratchpad toggle`, mirroring dockshell's
// `sidebar` IPC target.
ShellRoot {
    PanelWindow {
        id: root
        visible: false
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        WlrLayershell.namespace: "quickshell-scratchpad"

        IpcHandler {
            target: "scratchpad"
            function toggle(): string { root.visible = !root.visible; return "visible=" + root.visible; }
            function show(): string { root.visible = true; return "visible=true"; }
            function hide(): string { root.visible = false; return "visible=false"; }
        }

        // Click-to-close backdrop. Sits behind the dashboard in the child
        // list, so clicks landing on an actual panel (which owns its own
        // MouseArea) are consumed there first; only clicks on the empty
        // space around/between panels fall through to this one.
        MouseArea {
            anchors.fill: parent
            onClicked: root.visible = false

            Rectangle {
                anchors.fill: parent
                color: "#40000000"
            }
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: 8

            // Spans exactly the height of rightColumn below (top of
            // CalendarPanel to bottom of WeatherPanel, spacing included),
            // so it never needs to be kept in sync by hand.
            PreviewPanel {
                Layout.preferredHeight: rightColumn.height
            }

            ColumnLayout {
                id: rightColumn
                spacing: 24

                RowLayout {
                    spacing: 8
                    CalendarPanel {}
                    ControlsPanel {}
                    ButtonsPanel {}
                }
                RowLayout {
                    spacing: 8
                    WeatherPanel { id: weatherPanel }
                    // Matches WeatherPanel's content-driven height instead
                    // of its own fixed 135, so the row's bottom edge is flush.
                    PkgPanel { Layout.preferredHeight: weatherPanel.height }
                }
            }
        }
    }
}
