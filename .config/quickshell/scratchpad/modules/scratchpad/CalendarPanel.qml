import QtQuick
import QtQuick.Layouts
import "../../style"

// Standalone dockapp-styled calendar box, no Service — the month grid and
// ISO week number are cheap to compute directly from JS Date, unlike eww's
// scratchpad-cal which shells out to `date +%V` on a poll.
Rectangle {
    id: root
    implicitWidth: 170
    implicitHeight: 187
    color: Theme.bg
    border.color: Theme.border
    border.width: 1
    radius: 0

    readonly property var now: _clock.now
    readonly property int year: now.getFullYear()
    readonly property int month: now.getMonth()
    readonly property int today: now.getDate()
    readonly property int weekNumber: _isoWeek(now)
    readonly property var weeks: _buildMonth(year, month)

    QtObject {
        id: _clock
        property var now: new Date()
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: _clock.now = new Date()
    }

    function _isoWeek(date) {
        const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
        const dayNum = (d.getUTCDay() + 6) % 7;
        d.setUTCDate(d.getUTCDate() - dayNum + 3);
        const firstThursday = new Date(Date.UTC(d.getUTCFullYear(), 0, 4));
        const firstDayNum = (firstThursday.getUTCDay() + 6) % 7;
        firstThursday.setUTCDate(firstThursday.getUTCDate() - firstDayNum + 3);
        return 1 + Math.round((d - firstThursday) / (7 * 24 * 3600 * 1000));
    }

    // Returns 42 cells (6 rows x 7 cols, Monday-first) covering the full
    // month plus leading/trailing days from adjacent months to fill the grid.
    function _buildMonth(y, m) {
        const firstOfMonth = new Date(y, m, 1);
        const leading = (firstOfMonth.getDay() + 6) % 7;
        const daysInMonth = new Date(y, m + 1, 0).getDate();
        const cells = [];
        for (let i = 0; i < leading; i++) cells.push({ day: "", inMonth: false, isToday: false });
        for (let day = 1; day <= daysInMonth; day++) {
            cells.push({ day: String(day), inMonth: true, isToday: day === root.today });
        }
        while (cells.length < 42) cells.push({ day: "", inMonth: false, isToday: false });
        return cells;
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                text: "[CAL]"
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 0
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "//"
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 0
            }

            Item { Layout.fillWidth: true }
            Text {
                text: "WEEK " + root.weekNumber
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 12
                font.bold: true
                font.letterSpacing: 0
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 7
            rowSpacing: 1
            columnSpacing: 1

            Repeater {
                model: ["M", "T", "W", "T", "F", "S", "S"]
                delegate: Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 7
            rowSpacing: 1
            columnSpacing: 1

            Repeater {
                model: root.weeks
                delegate: Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: modelData.isToday ? Theme.todayBg : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: modelData.day
                        color: modelData.isToday ? Theme.accent : Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        font.bold: modelData.isToday
                    }
                }
            }
        }
    }
}
