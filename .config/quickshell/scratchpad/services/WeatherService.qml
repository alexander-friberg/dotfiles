pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "WeatherModel.js" as Model

// Ported from omarchy's weather panel (plugins/panels/weather/Panel.qml):
// wttr.in resolves an IP-based location and provides current conditions +
// forecast until Open-Meteo has coordinates to work with, then Open-Meteo
// (faster, bundles current+daily in one request) takes over the numbers.
// No location config here (unlike omarchy) — always IP auto-detect, same
// zero-config behavior this service had before.
Singleton {
    id: root

    property var report: null
    property var dailyForecastReport: null
    property string icon: ""
    property int forecastRetries: 0
    property int dailyForecastRetries: 0

    readonly property var areaInfo: report && report.nearest_area && report.nearest_area[0] ? report.nearest_area[0] : null
    readonly property string reportCountry: areaInfo && areaInfo.country && areaInfo.country[0] ? areaInfo.country[0].value : ""
    readonly property string location: areaInfo && areaInfo.areaName && areaInfo.areaName[0] ? areaInfo.areaName[0].value : ""

    readonly property var currentCondition: report && report.current_condition && report.current_condition[0] ? report.current_condition[0] : null
    readonly property string condition: currentCondition && currentCondition.weatherDesc && currentCondition.weatherDesc[0] ? currentCondition.weatherDesc[0].value : ""

    readonly property var openMeteoCurrent: Model.openMeteoCurrentCondition(dailyForecastReport)
    readonly property var current: openMeteoCurrent || currentCondition

    readonly property bool useImperial: Model.shouldUseImperial("", Qt.locale().name, reportCountry)

    readonly property string temp: current ? Model.formatTemp(useImperial ? current.temp_F : current.temp_C, useImperial) : ""
    readonly property string feelsLike: current ? Model.formatTemp(useImperial ? current.FeelsLikeF : current.FeelsLikeC, useImperial) : ""
    readonly property string wind: current ? (useImperial ? (current.windspeedMiles + " mph") : (current.windspeedKmph + " km/h")) : ""
    readonly property string humidity: current ? (current.humidity + "%") : ""

    readonly property var forecastDaysRaw: Model.buildForecastDays(report, dailyForecastReport, Qt.formatDate(new Date(), "yyyy-MM-dd"))
    readonly property var days: {
        var out = []
        for (var i = 0; i < forecastDaysRaw.length; i++) {
            var d = forecastDaysRaw[i]
            out.push({
                dayLabel: Model.dayName(d.date, function(date) { return Qt.formatDate(date, "ddd") }).toUpperCase(),
                icon: Model.dayIcon(d),
                maxText: Model.bareTempForDay(d, "max", useImperial),
                minText: Model.bareTempForDay(d, "min", useImperial)
            })
        }
        return out
    }

    function refresh() {
        forecastRetries = 0
        dailyForecastRetries = 0
        if (!forecastProc.running) forecastProc.running = true
    }

    function refreshDailyForecast(sourceReport) {
        if (dailyForecastProc.running) return

        var area = (sourceReport && sourceReport.nearest_area && sourceReport.nearest_area[0]) || root.areaInfo
        if (!area) return
        var lat = parseFloat(String(area.latitude || ""))
        var lon = parseFloat(String(area.longitude || ""))
        if (isNaN(lat) || isNaN(lon)) return

        var url = "https://api.open-meteo.com/v1/forecast"
            + "?latitude=" + encodeURIComponent(String(lat))
            + "&longitude=" + encodeURIComponent(String(lon))
            + "&daily=weather_code,temperature_2m_max,temperature_2m_min"
            + "&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code,is_day"
            + "&forecast_days=4"
            + "&timezone=auto"
        dailyForecastProc.command = ["curl", "-fsS", "--max-time", "5", url]
        dailyForecastProc.running = true
    }

    function scheduleForecastRetry() {
        if (forecastRetries >= 3) return
        forecastRetries++
        forecastRetryTimer.restart()
    }

    function scheduleDailyForecastRetry() {
        if (dailyForecastRetries >= 3) return
        dailyForecastRetries++
        dailyForecastRetryTimer.restart()
    }

    Process {
        id: forecastProc
        command: ["curl", "-fsS", "--max-time", "10", "https://wttr.in/?format=j1"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var raw = String(text || "").trim()
                if (!raw) {
                    root.scheduleForecastRetry()
                    return
                }
                try {
                    var parsed = JSON.parse(raw)
                    root.report = parsed
                    root.icon = Model.provisionalCurrentIcon(parsed.current_condition && parsed.current_condition[0], root.icon)
                    root.forecastRetries = 0
                    root.refreshDailyForecast(parsed)
                } catch (e) {
                    // Keep last-good report visible, but try again shortly.
                    root.scheduleForecastRetry()
                }
            }
        }
    }

    Process {
        id: dailyForecastProc
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var raw = String(text || "").trim()
                if (!raw) {
                    root.scheduleDailyForecastRetry()
                    return
                }
                try {
                    var parsed = JSON.parse(raw)
                    var parsedCurrent = Model.openMeteoCurrentCondition(parsed)
                    root.dailyForecastReport = parsed
                    root.icon = Model.currentIcon(parsedCurrent, root.icon)
                    root.dailyForecastRetries = 0
                } catch (e) {
                    // Keep last-good daily forecast visible, but try again shortly.
                    root.scheduleDailyForecastRetry()
                }
            }
        }
    }

    Timer {
        id: forecastRetryTimer
        interval: 2500
        onTriggered: if (!forecastProc.running) forecastProc.running = true
    }

    Timer {
        id: dailyForecastRetryTimer
        interval: 2500
        onTriggered: root.refreshDailyForecast(null)
    }

    Timer {
        interval: 15 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
