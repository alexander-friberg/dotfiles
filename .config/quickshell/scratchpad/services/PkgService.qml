pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
// Two independent pollers (system closure + flatpak) plus a lightweight
// generation read; NixOS has no pacman/AUR-style native-vs-foreign package
// split, so the middle slot instead reports the current system generation
// number as a proxy for "how long since the last rebuild" — the closest
// NixOS-native equivalent to watching an update count creep up.
Singleton {
    id: root
    property int system: 0
    property int generation: 0
    property int flatpak: 0
    readonly property int total: root.system + root.flatpak
    Process {
        id: systemProc
        command: ["sh", "-c", "nix-store -q --references /run/current-system/sw | wc -l"]
        stdout: StdioCollector {
            id: systemCollector
            onStreamFinished: {
                const n = parseInt(systemCollector.text.trim(), 10);
                if (!isNaN(n)) root.system = n;
            }
        }
    }
    Process {
        id: generationProc
        command: ["sh", "-c", "readlink /nix/var/nix/profiles/system"]
        stdout: StdioCollector {
            id: generationCollector
            onStreamFinished: {
                // symlink target looks like "system-157-link"
                const match = generationCollector.text.trim().match(/system-(\d+)-link/);
                if (match) root.generation = parseInt(match[1], 10);
            }
        }
    }
    Process {
        id: flatpakProc
        command: ["sh", "-c", "flatpak list | wc -l"]
        stdout: StdioCollector {
            id: flatpakCollector
            onStreamFinished: {
                const n = parseInt(flatpakCollector.text.trim(), 10);
                if (!isNaN(n)) root.flatpak = n;
            }
        }
    }
    Timer {
        interval: 600000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!systemProc.running) systemProc.running = true;
            if (!generationProc.running) generationProc.running = true;
            if (!flatpakProc.running) flatpakProc.running = true;
        }
    }
}
