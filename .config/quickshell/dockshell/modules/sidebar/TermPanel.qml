import QtQuick
import QtQuick.Layouts
import "../../style"
import "../../services"

Rectangle {
    id: root
    color: Theme.bg
    border.color: Theme.border
    border.width: 1
    implicitWidth: content.implicitWidth + 12
    implicitHeight: content.implicitHeight + 12

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 6
        spacing: 8

        Text {
            text: "[TERM]"
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: 12
            font.bold: true
        }

        // Off-layout reference row purely to measure a single item's real
        // height, same technique as DockerPanel.qml's measureRow — deriving
        // the box height from the ListView's own contentHeight instead
        // would make the panel resize itself the instant the model
        // mutates, a beat before the item-position animation below has
        // played out, which read as a second "jump" stacked on the slide.
        TermEventRow {
            id: measureRow
            visible: false
            eventType: "SPWN"
            pid: "measure"
        }

        // events is a ListModel (not a plain JS array) specifically so
        // insert/remove notify ListView incrementally — a reassigned JS
        // array model would reset wholesale each tick and the add/displaced
        // transitions below would never fire.
        ListView {
            id: eventList
            Layout.fillWidth: true
            Layout.preferredHeight: 3 * measureRow.implicitHeight + 2 * spacing
            spacing: 4
            // The add/remove transitions below deliberately start/end one
            // row-height outside the box (below for entering, above for
            // leaving) so the motion reads as continuous — without clip,
            // ListView doesn't clip to its own bounds by default, so that
            // off-box portion of the animation rendered past the panel's
            // border instead of being hidden, looking like items were
            // spawning outside the box.
            clip: true
            // Model index 0 is always the newest event (TermService.qml
            // inserts there and evicts from the far end) — BottomToTop
            // renders index 0 at the bottom and higher indices stacked
            // above it, so newest-at-bottom/scrolls-upward falls out of
            // that alone with no change needed on the service side.
            verticalLayoutDirection: ListView.BottomToTop
            model: TermService.events
            delegate: TermEventRow {
                width: eventList.width
                eventType: model.kind
                pid: model.pid
            }

            // Enters one row below its resting spot and slides up into
            // place. ViewTransition.destination.y (the real computed
            // resting position for this transition) is used as the anchor
            // rather than a flat offset from 0 — unlike the old top-entry
            // case, a bottom-inserted item's resting y depends on the
            // view's current content height, not a constant.
            add: Transition {
                NumberAnimation { property: "y"; from: ViewTransition.destination.y + measureRow.implicitHeight + eventList.spacing; duration: 150; easing.type: Easing.OutCubic }
            }
            displaced: Transition {
                NumberAnimation { property: "y"; duration: 150; easing.type: Easing.OutCubic }
            }
            // The departing item is now the top-most row (oldest, highest
            // index) — scrolls further up and off before fading, mirroring
            // "scrolls off the top".
            remove: Transition {
                NumberAnimation { property: "opacity"; to: 0; duration: 150; easing.type: Easing.OutCubic }
                NumberAnimation { property: "y"; to: y - measureRow.implicitHeight - eventList.spacing; duration: 150; easing.type: Easing.OutCubic }
            }
        }

        Text {
            visible: TermService.events.count === 0
            text: "no events yet"
            color: Theme.btDim
            font.family: Theme.fontFamily
            font.pixelSize: 10
        }
    }
}
