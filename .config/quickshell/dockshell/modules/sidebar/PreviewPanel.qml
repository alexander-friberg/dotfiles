import QtQuick
import QtMultimedia
import "../../style"

// Ported from scratchpad/modules/scratchpad/PreviewPanel.qml — same
// extension-sniffing so a gif or video can drop in later with no code
// change: `.gif` plays via QtQuick's built-in AnimatedImage, a video
// extension via QtMultimedia's Video (muted — decorative only), anything
// else falls back to a plain still Image. Framed with the same dockapp
// border as the other sidebar panels.
Rectangle {
    id: root
    implicitWidth: 150
    implicitHeight: 150
    color: Theme.bg
    border.color: Theme.border
    border.width: 1
    radius: 0
    clip: true

    property string source: "/home/alex/Pictures/thethinker.jpg"

    readonly property string _ext: {
        const m = root.source.match(/\.([a-zA-Z0-9]+)$/);
        return m ? m[1].toLowerCase() : "";
    }
    readonly property bool _isGif: root._ext === "gif"
    readonly property bool _isVideo: ["mp4", "webm", "mkv", "mov", "avi"].includes(root._ext)

    Image {
        anchors.fill: parent
        anchors.margins: root.border.width
        visible: !root._isGif && !root._isVideo
        source: visible ? root.source : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    AnimatedImage {
        anchors.fill: parent
        anchors.margins: root.border.width
        visible: root._isGif
        source: visible ? root.source : ""
        fillMode: Image.PreserveAspectCrop
        playing: visible
    }

    Loader {
        anchors.fill: parent
        anchors.margins: root.border.width
        active: root._isVideo
        sourceComponent: Video {
            anchors.fill: parent
            source: Qt.resolvedUrl(root.source)
            autoPlay: true
            loops: MediaPlayer.Infinite
            muted: true
            fillMode: VideoOutput.PreserveAspectCrop
        }
    }
}
