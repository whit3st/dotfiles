#!/usr/bin/env bash
# Polybar module: live battery power draw in watts. Reads sysfs only, no root.
# Output matches the bar's "gold prefix + plain value" style (#F0C674 = colors.primary).
# While discharging shows draw e.g. "PWR 9.8W"; while charging shows "PWR +42.0W".

BAT=/sys/class/power_supply/BAT0
PREFIX='%{F#F0C674}PWR %{F-}'

status=$(cat "$BAT/status" 2>/dev/null)
uw=$(cat "$BAT/power_now" 2>/dev/null)

# Fallback for gauges that expose current/voltage instead of power_now.
if [ -z "$uw" ] && [ -r "$BAT/current_now" ] && [ -r "$BAT/voltage_now" ]; then
	cn=$(cat "$BAT/current_now"); vn=$(cat "$BAT/voltage_now")
	uw=$(awk -v c="$cn" -v v="$vn" 'BEGIN{printf "%.0f", (c*v)/1000000}') # uA*uV -> uW
fi

if [ -z "$uw" ]; then
	printf '%s-\n' "$PREFIX"
	exit 0
fi

w=$(awk -v u="$uw" 'BEGIN{printf "%.1f", u/1000000}') # uW -> W

case "$status" in
	Charging) printf '%s+%sW\n' "$PREFIX" "$w" ;;
	*)        printf '%s%sW\n' "$PREFIX" "$w" ;;
esac
