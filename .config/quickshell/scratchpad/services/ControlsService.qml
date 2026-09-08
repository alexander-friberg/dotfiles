pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
// Brightness/volume are polled (brightnessctl/wpctl have no push/watch
// mode); nightlight state is owned here directly rather than polled, since
// hyprsunset has no query command — same reasoning as scratchpad.yuck's
// scratchpad-nightlight-on/-temp defvars, just QML properties instead of
// eww ones. Nightlight is driven with direct hyprctl calls rather than
// shelling out to scratchpad-nightlight.sh, since that script reads/writes
// its state via `eww get`/`eww update` — a dependency on the eww daemon
// this standalone QML config shouldn't need.
// Brightness/volume polling is done via brightnessctl/wpctl directly
// (parsed inline below) rather than the old eww helper scripts, for the
// same reason: no dependency outside this config directory.
Singleton {
    id: root
    property int brightness: 50
    property int volumePct: 50
    property bool volumeMuted: false
    property bool nightlightOn: false
    property int nightlightTemp: 4500
    readonly property int nightlightPercent: Math.round((root.nightlightTemp - 2500) / 4000 * 100)
    function setBrightness(pct) {
        setBrightnessProc.command = ["brightnessctl", "-e4", "-n2", "set", pct + "%"];
        setBrightnessProc.running = true;
    }
    function setVolume(pct) {
        setVolumeProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", pct + "%"];
        setVolumeProc.running = true;
    }
    function setNightlightPercent(pct) {
        const kelvin = 2500 + Math.round(pct * 4000 / 100);
        root.nightlightTemp = kelvin;
        if (root.nightlightOn) {
            nightlightTempProc.command = ["hyprctl", "hyprsunset", "temperature", String(kelvin)];
            nightlightTempProc.running = true;
        }
    }
    function toggleNightlight() {
        if (root.nightlightOn) {
            nightlightToggleProc.command = ["hyprctl", "hyprsunset", "identity"];
            nightlightToggleProc.running = true;
            root.nightlightOn = false;
        } else {
            nightlightToggleProc.command = ["hyprctl", "hyprsunset", "temperature", String(root.nightlightTemp)];
            nightlightToggleProc.running = true;
            root.nightlightOn = true;
        }
    }
    Process { id: setBrightnessProc }
    Process { id: setVolumeProc }
    Process { id: nightlightTempProc }
    Process { id: nightlightToggleProc }
    Process {
        id: brightnessPoll
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            id: brightnessCollector
            onStreamFinished: {
                // -m output: "<device>,<class>,<current>,<percentage>%,<max>"
                const parts = brightnessCollector.text.trim().split(",");
                if (parts.length >= 4) {
                    const pct = parseInt(parts[3], 10); // parseInt stops at the trailing '%'
                    if (!isNaN(pct)) root.brightness = pct;
                }
            }
        }
    }
    Process {
        id: volumePoll
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            id: volumeCollector
            onStreamFinished: {
                // Output: "Volume: 0.45" or "Volume: 0.45 [MUTED]"
                const text = volumeCollector.text.trim();
                const match = text.match(/Volume:\s*([0-9.]+)/);
                if (match) root.volumePct = Math.round(parseFloat(match[1]) * 100);
                root.volumeMuted = text.includes("MUTED");
            }
        }
    }
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!brightnessPoll.running) brightnessPoll.running = true
    }
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!volumePoll.running) volumePoll.running = true
    }
}
