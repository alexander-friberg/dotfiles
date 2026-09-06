pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Three independent pollers (pacman/aur/flatpak), each its own Process +
// Timer, so one slow/failing source never blocks the others. Counts total
// *installed* packages per source, not pending updates — pacman's own
// foreign-package accounting (-Qn native vs -Qm foreign) distinguishes repo
// packages from AUR/local ones without needing an AUR helper at all.
Singleton {
    id: root

    property int pacman: 0
    property int aur: 0
    property int flatpak: 0
    readonly property int total: root.pacman + root.aur + root.flatpak

    Process {
        id: pacmanProc
        command: ["sh", "-c", "pacman -Qnq | wc -l"]
        stdout: StdioCollector {
            id: pacmanCollector
            onStreamFinished: {
                const n = parseInt(pacmanCollector.text.trim(), 10);
                if (!isNaN(n)) root.pacman = n;
            }
        }
    }

    Process {
        id: aurProc
        command: ["sh", "-c", "pacman -Qmq | wc -l"]
        stdout: StdioCollector {
            id: aurCollector
            onStreamFinished: {
                const n = parseInt(aurCollector.text.trim(), 10);
                if (!isNaN(n)) root.aur = n;
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
            if (!pacmanProc.running) pacmanProc.running = true;
            if (!aurProc.running) aurProc.running = true;
            if (!flatpakProc.running) flatpakProc.running = true;
        }
    }
}
