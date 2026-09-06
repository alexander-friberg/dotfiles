pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property alias events: eventModel
    property bool seeded: false
    property var _knownPids: ({})
    property var _pollPid: null
    property int uid: -1
    property var _pending: []

    ListModel { id: eventModel }

    function _parsePids(text) {
        const set = {};
        const lines = text.split("\n");
        for (let i = 0; i < lines.length; i++) {
            const pid = lines[i].trim();
            if (pid) set[pid] = true;
        }
        return set;
    }

    // The first poll only seeds the known-PID baseline — without this guard
    // every already-running process on the system would fire as a "SPWN"
    // event the instant the widget starts.
    function _diff(current) {
        // The poller's own helper process is alive (and lists itself) at
        // the moment it enumerates /proc, then is gone by the next tick —
        // without excluding it, every single poll would manufacture a
        // guaranteed SPWN+KILL pair for its own `find` invocation and
        // drown out real events.
        if (root._pollPid !== null) delete current[root._pollPid];

        if (!root.seeded) {
            root._knownPids = current;
            root.seeded = true;
            return;
        }

        const fresh = [];
        for (const pid in current)
            if (!(pid in root._knownPids)) fresh.push({ kind: "SPWN", pid: pid });
        for (const pid in root._knownPids)
            if (!(pid in current)) fresh.push({ kind: "KILL", pid: pid });

        // Queued rather than inserted directly — a poll tick can surface
        // several events at once (e.g. a command that forks and exits
        // inside the same 1s window), and inserting them into eventModel
        // back-to-back in the same JS turn made the ListView's add/displaced
        // transitions overlap and compound into a visibly "weird" slide.
        // drainTimer below feeds them in one at a time instead.
        root._pending = root._pending.concat(fresh).slice(-6);

        root._knownPids = current;
    }

    Process {
        id: uidProc
        running: true
        command: ["id", "-u"]
        stdout: StdioCollector {
            onStreamFinished: root.uid = parseInt(text.trim(), 10)
        }
    }

    Process {
        id: pollProc
        // Run `find` directly rather than through `sh -c "... | ..."` so
        // there's exactly one helper pid to exclude below instead of three
        // (shell + ls + grep) coming and going every tick. -uid scopes this
        // to the current user's own processes, which also drops kernel
        // threads and root daemons out of the feed for free.
        command: ["find", "/proc", "-maxdepth", "1", "-regex", "/proc/[0-9]+", "-uid", String(root.uid), "-printf", "%f\n"]
        // Cached on change rather than read from pollProc.processId inside
        // _diff(), since that property's value once the process has already
        // exited (which is always true by the time onStreamFinished fires)
        // isn't documented/guaranteed to still hold the last pid.
        onProcessIdChanged: root._pollPid = pollProc.processId
        stdout: StdioCollector {
            id: collector
            onStreamFinished: root._diff(root._parsePids(collector.text))
        }
    }

    // Polls faster than DockerService's 3s — a process that spawns and
    // exits entirely between two polls is invisible either way, so a
    // tighter interval matters more here than it does for container state.
    Timer {
        interval: 1000
        running: root.uid >= 0
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!pollProc.running) pollProc.running = true
    }

    // Feeds _pending into eventModel one at a time, well clear of the
    // 150ms add/displaced transition duration in TermPanel.qml, so each
    // insertion's animation fully settles before the next one lands.
    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            if (root._pending.length === 0) return;
            const ev = root._pending[0];
            root._pending = root._pending.slice(1);
            eventModel.insert(0, ev);
            while (eventModel.count > 3) eventModel.remove(eventModel.count - 1);
        }
    }
}
