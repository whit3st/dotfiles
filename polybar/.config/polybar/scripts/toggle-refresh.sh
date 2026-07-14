#!/usr/bin/env bash
# Toggle the internal (eDP) panel between 60 Hz and 120 Hz, then ask polybar
# to redraw its refresh module immediately. No root required.

OUT=eDP
MODE=2880x1800

# Pure, testable helper: given the current rate, return the other one.
# Unknown/empty input falls back to 120 (safe: restores the nicer rate).
next_rate() {
	case "$1" in
		120*) echo 60 ;;
		*)    echo 120 ;;
	esac
}

_main() {
	local cur new
	cur=$(xrandr --query 2>/dev/null \
		| sed -n "/^${OUT} connected/,/^[^ ]/p" \
		| grep -oP '[0-9]+(\.[0-9]+)?(?=\*)' \
		| head -1)
	new=$(next_rate "$cur")
	xrandr --output "$OUT" --mode "$MODE" --rate "$new"

	# Nudge the polybar custom/ipc "refresh" module to update now.
	polybar-msg action "#refresh.hook.0" >/dev/null 2>&1 \
		|| polybar-msg hook refresh 1 >/dev/null 2>&1 \
		|| true
}

# Only run when executed directly, so tests can source next_rate() cleanly.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	_main
fi
