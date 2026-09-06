pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../style"

Singleton {
    id: root

    property var containers: []

    // Only a non-zero exit code gets the hollow/exited treatment — a
    // clean exit (code 0) is just "stopped", shown filled like any other
    // non-exceptional state.
    function _statusFor(state) {
        const status = state.Status;
        if (status === "running") return { color: Theme.accent, exited: false, exitCode: 0 };
        if (status === "restarting") return { color: Theme.dockerRestarting, exited: false, exitCode: 0 };
        if (status === "exited") {
            if (state.ExitCode === 0) return { color: Theme.btDim, exited: false, exitCode: 0 };
            return { color: Theme.dockerExited, exited: true, exitCode: state.ExitCode };
        }
        return { color: Theme.btDim, exited: false, exitCode: 0 };
    }

    function _parse(text) {
        const result = [];
        const lines = text.split("\n");
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i].trim();
            if (!line) continue;
            let obj;
            try { obj = JSON.parse(line); } catch (e) { continue; }
            const status = root._statusFor(obj.State);
            result.push({
                id: obj.Id,
                name: obj.Name ? obj.Name.replace(/^\//, "") : obj.Id.substring(0, 12),
                color: status.color,
                exited: status.exited,
                exitCode: status.exitCode
            });
        }
        return result;
    }

    function stopContainer(id) {
        stopProc.command = ["docker", "stop", id];
        stopProc.running = true;
    }

    function restartContainer(id) {
        restartProc.command = ["docker", "restart", id];
        restartProc.running = true;
    }

    function openLogs(id) {
        logsProc.command = ["kitty", "--class", "kitty-docker-logs", "-e", "docker", "logs", "-f", id];
        logsProc.startDetached();
    }

    Process { id: stopProc }
    Process { id: restartProc }
    Process { id: logsProc }

    Process {
        id: pollProc
        command: ["sh", "-c", "docker inspect --format '{{json .}}' $(docker ps -aq) 2>/dev/null"]
        stdout: StdioCollector {
            id: collector
            onStreamFinished: root.containers = root._parse(collector.text)
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!pollProc.running) pollProc.running = true
    }
}
