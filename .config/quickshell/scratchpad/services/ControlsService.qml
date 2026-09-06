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
        command: ["/home/alex/.config/eww/scripts/scratchpad-brightness.sh"]
        stdout: StdioCollector {
            id: brightnessCollector
            onStreamFinished: {
                const n = parseInt(brightnessCollector.text.trim(), 10);
                if (!isNaN(n)) root.brightness = n;
            }
        }
    }

    Process {
        id: volumePoll
        command: ["/home/alex/.config/eww/scripts/scratchpad-volume.sh"]
        stdout: StdioCollector {
            id: volumeCollector
            onStreamFinished: {
                try {
                    const obj = JSON.parse(volumeCollector.text.trim());
                    if (obj.pct !== undefined) root.volumePct = obj.pct;
                    if (obj.muted !== undefined) root.volumeMuted = obj.muted;
                } catch (e) {}
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
