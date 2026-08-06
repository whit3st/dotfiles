#!/usr/bin/env bash
# Polybar module: battery percent + power draw, combined. Reads sysfs only, no root.
# Output e.g. "BAT 54% | 12W"; while charging "CHR 54% | +42W".

BAT=/sys/class/power_supply/BAT0
LOW_AT=15

battery_prefix() { # $1 status  $2 percent -> "BAT " / "CHR " / "FULL " / "LOW "
	local status="$1" percent="$2"
	case "$status" in
		Charging) echo "CHR " ;;
		Full)     echo "FULL " ;;
		*)
			if [ -n "$percent" ] && [ "$percent" -le "$LOW_AT" ] 2>/dev/null; then
				echo "LOW "
			else
				echo "BAT "
			fi
			;;
	esac
}

watts_from_uw() { # $1 microwatts -> watts, 1 decimal
	awk -v u="$1" 'BEGIN{printf "%.1f", u/1000000}'
}

power_sign() { # $1 status -> "+" while charging, else ""
	[ "$1" = "Charging" ] && echo "+" || echo ""
}

_main() {
	local status percent uw cn vn w prefix sign color

	status=$(cat "$BAT/status" 2>/dev/null)
	percent=$(cat "$BAT/capacity" 2>/dev/null)
	uw=$(cat "$BAT/power_now" 2>/dev/null)

	if [ -z "$uw" ] && [ -r "$BAT/current_now" ] && [ -r "$BAT/voltage_now" ]; then
		cn=$(cat "$BAT/current_now"); vn=$(cat "$BAT/voltage_now")
		uw=$(awk -v c="$cn" -v v="$vn" 'BEGIN{printf "%.0f", (c*v)/1000000}') # uA*uV -> uW
	fi

	prefix=$(battery_prefix "$status" "$percent")
	sign=$(power_sign "$status")
	color='#F0C674'
	[ "$prefix" = "LOW " ] && color='#A54242'

	if [ -z "$percent" ]; then
		printf '%%{F%s}%s%%{F-}-\n' "$color" "$prefix"
		return
	fi

	if [ -z "$uw" ]; then
		printf '%%{F%s}%s%%{F-}%s%%\n' "$color" "$prefix" "$percent"
		return
	fi

	w=$(watts_from_uw "$uw")
	printf '%%{F%s}%s%%{F-}%s%% | %s%sW\n' "$color" "$prefix" "$percent" "$sign" "$w"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
	_main
fi
