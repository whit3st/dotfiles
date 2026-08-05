#!/usr/bin/env bash
# Polybar module: average CPU frequency across all cores, in GHz. No root.
# Output e.g. "FRQ 1.83GHz". Colour #F0C674 matches colors.primary in config.ini.

PREFIX='%{F#F0C674}FRQ %{F-}'

ghz=$(awk '
	{ sum += $1; n++ }
	END { if (n > 0) printf "%.2f", (sum / n) / 1000000 }
' /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_cur_freq 2>/dev/null)

[ -z "$ghz" ] && ghz='?'

printf '%s%sGHz\n' "$PREFIX" "$ghz"
