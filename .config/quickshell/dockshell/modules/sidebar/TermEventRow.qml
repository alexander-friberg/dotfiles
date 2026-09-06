import QtQuick
import QtQuick.Layouts
import "../../style"

Item {
    id: root
    property string eventType: "SPWN"
    property string pid: ""

    implicitHeight: rowText.implicitHeight + 8

    Rectangle {
        anchors.fill: parent
        border.color: Theme.btDivider
        border.width: 1
        color: "transparent"
    }

    RowLayout {
        id: rowText
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 5
        spacing: 5

        Text {
            text: "$:"
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.bold: true
        }

        // nf-fa-check / nf-fa-times — actual Nerd Font glyph codepoints
        // rather than plain Unicode dingbats (✓/✖), since those aren't
        // guaranteed to be in JetBrainsMono Nerd Font's base charset — the
        // same silent-rendering-gap failure mode already hit once this
        // session with the "| " divider text.
        Text {
            text: root.eventType === "SPWN" ? "" : ""
            color: root.eventType === "SPWN" ? Theme.termSpawn : Theme.termKill
            font.family: Theme.fontFamily
            font.pixelSize: 11
            font.bold: true
        }

        // No Layout.fillWidth/elide here on purpose: with the timestamp
        // gone, "pid 12345" is short enough to never approach the box's
        // real width, and a fillWidth+elide Text inside a freshly-created
        // ListView delegate turned out to be genuinely flaky here — it
        // sometimes elides against a stale pre-layout width and never
        // re-settles even once the RowLayout's real (much wider) width is
        // known. A plain natural-width Text sidesteps that bug entirely.
        Text {
            text: "pid " + root.pid
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: 11
        }
    }
}
