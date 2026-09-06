import QtQuick
import QtQuick.Layouts
import "../../style"
import "../../services"

// [WTHR] dockapp: icon + current temp/condition/feels-hum-wind on the left,
// a 3-day icon forecast strip on the right. Data/icons come from
// WeatherService (ported from omarchy's weather panel: wttr.in for
// auto-located current conditions + forecast, Open-Meteo for faster,
// day/night-aware current conditions once a location is resolved).
Rectangle {
    id: root
    implicitWidth: 356
    implicitHeight: column.implicitHeight + 12
    color: Theme.bg
    border.color: Theme.border
    border.width: 1
    radius: 0
    clip: true

    readonly property string subline: [
        WeatherService.feelsLike !== "" ? ("Feels " + WeatherService.feelsLike) : "",
        WeatherService.wind,
        WeatherService.humidity !== "" ? (WeatherService.humidity + " hum") : ""
    ].filter(function(s) { return s !== "" }).join(" · ")

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 6
        spacing: 4

        Text {
            text: "[WTHR]"
            color: Theme.fg
            font.family: Theme.fontFamily
            font.pixelSize: 17
            font.bold: true
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: WeatherService.icon
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: 26
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 1

                Text {
                    text: WeatherService.temp !== "" ? WeatherService.temp : "—"
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: 20
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Text {
                    text: WeatherService.condition
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Text {
                    text: root.subline
                    color: Theme.dim
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: WeatherService.days
                delegate: ColumnLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData.icon
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: 15
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData.dayLabel
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: "↑" + modelData.maxText + " ↓" + modelData.minText
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
