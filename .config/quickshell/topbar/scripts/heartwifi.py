#!/usr/bin/env python3

import json
import math
import subprocess
import time


GLYPH = "\u2593"  # ▪  (swap for "\u2665" = ♥, or "\u2588" for a plain block)

# Static text placed around the bars, e.g. "[" and "]" for "[ ▪▪▪▪▪ ]".
# Left/right stay plain (unpulsed, uncolored) — only the glyphs between
# them get Pango color spans. Set either to "" to disable.
BRACKET_LEFT = ""
BRACKET_RIGHT = ""

# Colors reused from the original heart script's palette.
COLOR_ACTIVE = "#cba6f7"   # green  — bar reached
COLOR_INACTIVE = "#5c5c5c"  # gray   — bar not reached
COLOR_DOWN = "#f38ba8"      # red    — no wifi / no internet

PULSE_PERIOD_MS = 1600  # how fast the top reached bar breathes
DIM_FACTOR = 0.35        # how dark the trough of the pulse gets (0-1, never 0)

BAR_COUNT = 5
# Signal % thresholds — bar i is "reached" once signal% >= THRESHOLDS[i].
# Even 20-wide bands across 0-100.
THRESHOLDS = [20 * i for i in range(BAR_COUNT)]  # [0, 20, 40, 60, 80]

TICK_MS = 100              # how often a new frame is printed (animation smoothness)
METRIC_REFRESH_MS = 1000   # how often signal/connectivity is actually re-measured
PING_HOST = "1.1.1.1"      # lightweight connectivity check target
PING_TIMEOUT_S = 1

# ---------------------------------------------------------------------------


def hex_to_rgb(hex_color: str) -> tuple[int, int, int]:
    hex_color = hex_color.lstrip("#")
    r, g, b = (int(hex_color[i:i + 2], 16) for i in (0, 2, 4))
    return (r, g, b)


# Precomputed once at import time, so the hot path (render(), called every
# TICK_MS) never has to re-parse hex strings.
_RGB_ACTIVE = hex_to_rgb(COLOR_ACTIVE)
_RGB_INACTIVE = hex_to_rgb(COLOR_INACTIVE)
_RGB_DOWN = hex_to_rgb(COLOR_DOWN)


def clamp(value: float, lo: float = 0.0, hi: float = 100.0) -> float:
    return max(lo, min(hi, value))


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def get_wifi_info() -> tuple[int, str] | None:
    """Returns (signal_percent, ssid) for the active wifi connection via
    NetworkManager, or None if there's no active wifi link at all."""
    try:
        out = subprocess.run(
            ["nmcli", "-t", "-f", "ACTIVE,SIGNAL,SSID", "dev", "wifi"],
            capture_output=True, text=True, timeout=2,
        )
    except (subprocess.SubprocessError, FileNotFoundError):
        return None

    for line in out.stdout.strip().splitlines():
        # Format: "yes:78:MyNetwork" — ACTIVE:SIGNAL:SSID. SSID can
        # itself contain ":" so we only split the first two fields off.
        parts = line.split(":", 2)
        if len(parts) >= 2 and parts[0] == "yes":
            try:
                signal = int(parts[1])
            except ValueError:
                return None
            ssid = parts[2] if len(parts) > 2 else "unknown"
            return signal, ssid
    return None


def has_internet() -> bool:
    """Single lightweight ping to check actual internet reachability,
    not just wifi association."""
    try:
        result = subprocess.run(
            ["ping", "-c", "1", "-W", str(PING_TIMEOUT_S), PING_HOST],
            capture_output=True, timeout=PING_TIMEOUT_S + 1,
        )
        return result.returncode == 0
    except subprocess.SubprocessError:
        return False


def get_bars_reached(signal_percent: int) -> int:
    """How many of the 5 bars are 'reached' at this signal level."""
    reached = 0
    for threshold in THRESHOLDS:
        if signal_percent >= threshold:
            reached += 1
    return reached


class NetState:
    """down=True means show all-red. Otherwise bars_reached (0-5) tells
    us how many bars are lit, and the top lit bar pulses.

    ssid/signal/linked are carried along purely for the tooltip text —
    they don't affect rendering."""

    def __init__(self, down: bool, bars_reached: int, ssid: str | None,
                 signal: int | None, linked: bool):
        self.down = down
        self.bars_reached = bars_reached
        self.ssid = ssid
        self.signal = signal
        self.linked = linked


def get_net_state() -> NetState:
    info = get_wifi_info()

    if info is None:
        # No active wifi link at all.
        return NetState(down=True, bars_reached=0, ssid=None, signal=None, linked=False)

    signal, ssid = info

    if not has_internet():
        # Linked to wifi but no actual internet.
        return NetState(down=True, bars_reached=0, ssid=ssid, signal=signal, linked=True)

    return NetState(
        down=False,
        bars_reached=get_bars_reached(signal),
        ssid=ssid,
        signal=signal,
        linked=True,
    )


def render(state: NetState) -> str:
    now_ms = time.time() * 1000
    phase = (now_ms % PULSE_PERIOD_MS) / PULSE_PERIOD_MS      # 0..1
    pulse = (math.sin(phase * 2 * math.pi) + 1) / 2            # 0..1, smooth in/out
    brightness = lerp(DIM_FACTOR, 1.0, pulse)

    spans = []
    for i in range(BAR_COUNT):
        bar_num = i + 1  # 1-indexed, matches "bars_reached" count

        if state.down:
            color = _RGB_DOWN  # solid, no pulse
        elif bar_num > state.bars_reached:
            color = _RGB_INACTIVE  # solid gray, no pulse
        elif bar_num == state.bars_reached:
            # Top reached bar: pulses to show current level.
            shaded = tuple(round(c * brightness) for c in _RGB_ACTIVE)
            color = shaded
        else:
            color = _RGB_ACTIVE  # solid, bar below current level

        hex_color = "#%02x%02x%02x" % color
        spans.append(f"<span foreground='{hex_color}'>{GLYPH}</span>")

    return BRACKET_LEFT + "".join(spans) + BRACKET_RIGHT


def render_tooltip(state: NetState) -> str:
    if not state.linked:
        return "No wifi connection"
    if state.down:
        return f"{state.ssid} — connected, no internet"
    return f"{state.ssid} — {state.signal}% signal ({state.bars_reached}/{BAR_COUNT} bars)"


def run_loop() -> None:
    state = get_net_state()
    last_refresh = time.time()

    while True:
        now = time.time()
        if (now - last_refresh) * 1000 >= METRIC_REFRESH_MS:
            state = get_net_state()
            last_refresh = now

        payload = {"text": render(state), "tooltip": render_tooltip(state)}

        # flush=True is required: stdout isn't a TTY when Waybar reads it,
        # so Python block-buffers by default and Waybar wouldn't see any
        # output until the buffer filled up.
        print(json.dumps(payload), flush=True)
        time.sleep(TICK_MS / 1000)


def main() -> None:
    try:
        run_loop()
    except (BrokenPipeError, KeyboardInterrupt):
        pass


if __name__ == "__main__":
    main()
