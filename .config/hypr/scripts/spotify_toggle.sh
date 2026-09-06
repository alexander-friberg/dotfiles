#!/bin/bash
sock=$(ls -t /run/user/$(id -u)/hypr/*/.socket.sock 2>/dev/null | head -n1)
export HYPRLAND_INSTANCE_SIGNATURE=$(basename "$(dirname "$sock")")
if hyprctl clients | grep -q "class: spotify_terminal"; then
    hyprctl dispatch 'hl.dsp.workspace.toggle_special("spotify")'
else
    ~/.config/hypr/scripts/spotify_launch.sh
    sleep 2
    hyprctl dispatch 'hl.dsp.workspace.toggle_special("spotify")'
fi
