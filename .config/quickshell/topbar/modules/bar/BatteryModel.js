function clampFraction(value) {
  return Math.max(0, Math.min(1, value))
}

function batteryFraction(device) {
  return device && device.isPresent ? clampFraction(device.percentage) : 0
}

// Ported from omarchy's power panel: a Charging state with a near-zero
// changeRate or a multi-hour timeToFull means the firmware is holding the
// charge at a configured threshold rather than actually charging.
function chargeThresholdActive(device, onBattery, states) {
  var d = device || {}
  if (!(d.isPresent && !onBattery)) return false

  var fraction = batteryFraction(d)
  if (d.state === states.Discharging) return false
  if (d.state === states.PendingCharge) return true
  if (d.state === states.FullyCharged && fraction < 0.99) return true
  if (d.state !== states.Charging || fraction >= 0.99) return false

  return Number(d.changeRate || 0) <= 0.2 || Number(d.timeToFull || 0) >= 8 * 60 * 60
}

function modeLabel(device, onBattery, states) {
  var d = device || {}
  if (!d.isPresent) return ""

  if (chargeThresholdActive(d, onBattery, states)) return "Holding at threshold"
  if (onBattery) return "Discharging"
  if (batteryFraction(d) >= 1) return "Fully charged"
  return "Charging"
}

function profileIcon(profile, profiles) {
  if (profile === profiles.PowerSaver) return "󰌪"
  if (profile === profiles.Performance) return "󰓅"
  return "󰊚"
}

function profileLabel(profile, profiles) {
  if (profile === profiles.PowerSaver) return "Power saver"
  if (profile === profiles.Performance) return "Performance"
  return "Balanced"
}

function formatDuration(seconds) {
  var total = Math.round(Number(seconds || 0))
  if (total <= 0) return "—"
  var h = Math.floor(total / 3600)
  var m = Math.round((total % 3600) / 60)
  if (h <= 0) return m + "m"
  if (m <= 0) return h + "h"
  return h + "h " + m + "m"
}

function formatWh(value) {
  return Number(value || 0).toFixed(1) + " Wh"
}

function formatRate(value) {
  return Number(value || 0).toFixed(1) + " W"
}
