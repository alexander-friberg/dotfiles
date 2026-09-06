pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int historyLength: 60

    property real cpuPercent: 0
    property real ramPercent: 0
    property real tempC: 0
    property real swapPercent: 0

    property var cpuHistory: []
    property var ramHistory: []
    property var tempHistory: []
    property var swapHistory: []

    property string tempSensorPath: ""
    property var _prevCpu: null

    function _pushHistory(arr, value) {
        const next = arr.concat([value]);
        if (next.length > historyLength) next.shift();
        return next;
    }

    function _parseCpuLine(text) {
        const line = text.split("\n")[0];
        const parts = line.trim().split(/\s+/).slice(1).map(Number);
        const idle = parts[3] + parts[4];
        const total = parts.reduce((a, b) => a + b, 0);
        return { idle: idle, total: total };
    }

    function _tick() {
        statFile.reload();
        const cur = _parseCpuLine(statFile.text());
        if (root._prevCpu) {
            const totalDelta = cur.total - root._prevCpu.total;
            const idleDelta = cur.idle - root._prevCpu.idle;
            root.cpuPercent = totalDelta > 0 ? (1 - idleDelta / totalDelta) * 100 : 0;
            root.cpuHistory = root._pushHistory(root.cpuHistory, root.cpuPercent);
        }
        root._prevCpu = cur;

        memFile.reload();
        const mem = {};
        const lines = memFile.text().split("\n");
        for (let i = 0; i < lines.length; i++) {
            const m = lines[i].match(/^(\w+):\s+(\d+)/);
            if (m) mem[m[1]] = Number(m[2]);
        }
        if (mem.MemTotal) {
            root.ramPercent = (1 - mem.MemAvailable / mem.MemTotal) * 100;
            root.ramHistory = root._pushHistory(root.ramHistory, root.ramPercent);
        }
        if (mem.SwapTotal) {
            root.swapPercent = mem.SwapTotal > 0 ? (1 - mem.SwapFree / mem.SwapTotal) * 100 : 0;
            root.swapHistory = root._pushHistory(root.swapHistory, root.swapPercent);
        }

        if (root.tempSensorPath) {
            tempFile.reload();
            const raw = Number(tempFile.text().trim());
            if (!isNaN(raw)) {
                root.tempC = raw / 1000;
                root.tempHistory = root._pushHistory(root.tempHistory, root.tempC);
            }
        }
    }

    FileView { id: statFile; path: "/proc/stat"; printErrors: false }
    FileView { id: memFile; path: "/proc/meminfo"; printErrors: false }
    FileView { id: tempFile; path: root.tempSensorPath || "/proc/stat"; printErrors: false }

    // Resolve the thinkpad CPU hwmon temp path once at startup, mirroring
    // how eww's EWW_TEMPS.THINKPAD_CPU groups hwmon sensors by name+label.
    Process {
        id: sensorFinder
        command: ["sh", "-c",
            "for f in /sys/class/hwmon/*/name; do d=$(dirname \"$f\"); " +
            "[ \"$(cat \"$f\")\" = thinkpad ] || continue; " +
            "for l in \"$d\"/temp*_label; do " +
            "[ \"$(cat \"$l\")\" = CPU ] && echo \"${l%_label}_input\"; done; done"]
        stdout: SplitParser {
            onRead: data => { if (data.trim()) root.tempSensorPath = data.trim(); }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root._tick()
    }

    Component.onCompleted: sensorFinder.running = true
}
