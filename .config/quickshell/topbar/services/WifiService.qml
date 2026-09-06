pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Spawns the existing ~/.config/waybar/scripts/heartwifi.py as a
// long-running process and reads its continuous JSON-lines output
// (same protocol Waybar's custom/heart-wifi module consumes), rather than
// reimplementing its signal polling / pulse-brightness math in QML. The
// script already owns that logic; this just relays it.
Singleton {
    id: root

    property string markupText: "[ ]"
    property string tooltipText: ""

    function _pangoToRichText(text) {
        return text
            .replace(/<span foreground='([^']+)'>/g, "<font color='$1'>")
            .replace(/<\/span>/g, "</font>");
    }

    Process {
        id: proc
        running: true
        command: ["sh", "-c", "exec python3 ~/.config/quickshell/topbar/scripts/heartwifi.py"]
        stdout: SplitParser {
            onRead: data => {
                if (!data.trim()) return;
                let payload;
                try { payload = JSON.parse(data); } catch (e) { return; }
                root.markupText = root._pangoToRichText(payload.text);
                root.tooltipText = payload.tooltip;
            }
        }
    }
}
