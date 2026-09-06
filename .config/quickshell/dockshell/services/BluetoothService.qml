pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var allDevices: adapter ? adapter.devices.values : []

    // A phone/mouse+headphones combo can both be connected at once — eww's
    // original bt.connected/has_connected assumed a single device, but
    // Quickshell's per-device model doesn't have that limit, so this stays
    // a list rather than picking just the first match.
    readonly property var connectedDevices: {
        const result = [];
        for (let i = 0; i < allDevices.length; i++) {
            if (allDevices[i].connected) result.push(allDevices[i]);
        }
        return result;
    }

    // bluetoothctl's placeholder name for a device it couldn't get a real
    // name from is that device's own MAC address with colons swapped for
    // dashes (e.g. "74-B0-63-9A-35-DD") — a BlueZ Alias fallback, so
    // Quickshell's device.name exhibits the same placeholder. Only prune
    // this from not-yet-paired discovered devices; paired ones are kept
    // regardless of name, matching bluetooth-listen.sh's
    // prune_unnamed_discovered().
    function _isPlaceholderName(name, address) {
        if (!name) return true;
        return name.toUpperCase() === address.replace(/:/g, "-").toUpperCase();
    }

    readonly property var otherDevices: {
        const result = [];
        for (let i = 0; i < allDevices.length; i++) {
            const d = allDevices[i];
            if (d.connected) continue;
            if (!d.paired && _isPlaceholderName(d.name || d.deviceName, d.address)) continue;
            result.push(d);
        }
        return result;
    }

    property int scanDots: 1

    function togglePower() {
        if (adapter) adapter.enabled = !adapter.enabled;
    }

    function toggleScan() {
        if (!adapter) return;
        if (adapter.discovering) {
            adapter.discovering = false;
        } else {
            adapter.discovering = true;
            scanTimeout.restart();
        }
    }

    Timer {
        id: scanTimeout
        interval: 10000
        onTriggered: if (root.adapter) root.adapter.discovering = false
    }

    Timer {
        interval: 500
        running: root.adapter ? root.adapter.discovering : false
        repeat: true
        onTriggered: root.scanDots = (root.scanDots % 3) + 1
    }
}
