#!/bin/bash
sock=$(ls -t /run/user/$(id -u)/hypr/*/.socket.sock 2>/dev/null | head -n1)
export HYPRLAND_INSTANCE_SIGNATURE=$(basename "$(dirname "$sock")")
kitty --class spotify_terminal -e spotify_player &
sleep 1
hyprctl dispatch 'hl.dsp.window.move({ workspace = "special:spotify", follow = false })'
