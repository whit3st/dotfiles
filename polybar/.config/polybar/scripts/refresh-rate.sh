#!/usr/bin/env bash
# Polybar module: current eDP refresh rate. No root. Output e.g. "REF 120Hz".
# Colour #F0C674 matches colors.primary in config.ini.

PREFIX='%{F#F0C674}REF %{F-}'

# The active mode is the one marked with '*' in the eDP block of `xrandr`.
rate=$(xrandr --query 2>/dev/null \
	| sed -n '/^eDP connected/,/^[^ ]/p' \
	| grep -oP '[0-9]+(\.[0-9]+)?(?=\*)' \
	| head -1)
rate=${rate%.*}
[ -z "$rate" ] && rate='?'

printf '%s%sHz\n' "$PREFIX" "$rate"
