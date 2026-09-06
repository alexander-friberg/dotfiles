pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Four fire-and-forget actions — startDetached() so they outlive this
// Process element regardless of UI reloads, same pattern DockerService uses
// for its "open logs" action.
Singleton {
    id: root

    function sleep() {
        sleepProc.command = ["/home/alex/.config/eww/scripts/scratchpad-sleep.sh"];
        sleepProc.startDetached();
    }

    function exit() {
        // Not `hyprctl dispatch exit` — this session is UWSM-managed
        // (Hyprland runs as systemd user units), and that only quits the
        // compositor process without cleanly tearing down the session.
        // `uwsm stop` is UWSM's own logout command for that.
        exitProc.command = ["uwsm", "stop"];
        exitProc.startDetached();
    }

    function reboot() {
        rebootProc.command = ["systemctl", "reboot"];
        rebootProc.startDetached();
    }

    function poweroff() {
        poweroffProc.command = ["systemctl", "poweroff"];
        poweroffProc.startDetached();
    }

    Process { id: sleepProc }
    Process { id: exitProc }
    Process { id: rebootProc }
    Process { id: poweroffProc }
}
