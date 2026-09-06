pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property color bg: "#801e1e2e"
    readonly property color border: "#b4befe"
    readonly property color fg: "#cdd6f4"
    readonly property color accent: "#cba6f7"

    readonly property color cpuLine: "#378E65"
    readonly property color ramLine: "#5064A5" 
    readonly property color tmpLine: "#CA7238"
    readonly property color swpLine: "#E2432D"

    readonly property string fontFamily: "IosevkaTermSlab Nerd Font Mono"
    readonly property int spacing: 4

    readonly property color btDim: "#99ffffff"
    readonly property color btDivider: "#4dffffff"
    readonly property color btConnectedDot: "#00bacf"
    readonly property color btScanBorder: "#99ffffff"

    readonly property color dockerExited: "#f38ba8"
    readonly property color dockerRunning: "#a6e3a1"
    readonly property color dockerRestarting: "#00ffea"

    readonly property color termSpawn: "#87ff5b"
    readonly property color termKill: "#ff5b5b"
}
