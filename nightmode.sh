#!/bin/bash

# active monitor
MONITOR=$(xrandr | grep " connected" | cut -d' ' -f1)

if [ "$1" == "on" ]; then
    xrandr --output "$MONITOR" --gamma 1.0:0.8:0.6
    echo "Blue light filter active."
elif [ "$1" == "off" ]; then
    xrandr --output "$MONITOR" --gamma 1.0:1.0:1.0
    echo "Blue light filter disabled."
else
    echo "Usage: nightmode.sh [on|off]"
fi
