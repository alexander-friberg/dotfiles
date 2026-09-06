import QtQuick.Layouts
import "../../services"
import "../../style"

GridLayout {
    columns: 2
    rowSpacing: 4
    columnSpacing: 4

    SysCell {
        label: "[CPU]"
        value: SysStatsService.cpuPercent
        history: SysStatsService.cpuHistory
        min: 0; max: 100
        lineColor: Theme.cpuLine
    }
    SysCell {
        label: "[RAM]"
        value: SysStatsService.ramPercent
        history: SysStatsService.ramHistory
        min: 0; max: 100
        lineColor: Theme.ramLine
    }
    SysCell {
        label: "[TMP]"
        value: SysStatsService.tempC
        history: SysStatsService.tempHistory
        min: 30; max: 90
        lineColor: Theme.tmpLine
    }
    SysCell {
        label: "[SWP]"
        value: SysStatsService.swapPercent
        history: SysStatsService.swapHistory
        min: 0; max: 100
        lineColor: Theme.swpLine
    }
}
