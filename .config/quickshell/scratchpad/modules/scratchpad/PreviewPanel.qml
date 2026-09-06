import QtQuick
import QtMultimedia
import "../../style"

// Preview panel — see scratchpad-preview in scratchpad.yuck, currently a
// static photo. Picks its media type from `source`'s file extension so a
// gif or video can be dropped in later with no code change: `.gif` plays
// via QtQuick's built-in AnimatedImage, a video extension via QtMultimedia's
// Video (muted — this is a silent decorative loop), anything else falls
// back to a plain still Image, matching the current behavior. Framed with
// the same dockapp border as the other panels.
Rectangle {
    id: root
    implicitWidth: 198
    implicitHeight: 346
    color: Theme.bg
    border.color: Theme.border
    border.width: 1
    radius: 0
    clip: true

    property string source: "/home/alex/.config/quickshell/scratchpad/Tokio.mp4"

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
