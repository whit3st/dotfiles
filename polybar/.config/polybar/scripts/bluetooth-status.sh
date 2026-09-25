#!/usr/bin/env bash

if timeout 2 bluetoothctl show 2>/dev/null | grep -q '^[[:space:]]*Powered: yes$'; then
	printf '%%{F#F0C674}BT%%{F-} on\n'
else
	printf '%%{F#F0C674}BT%%{F#707880} off%%{F-}\n'
fi
