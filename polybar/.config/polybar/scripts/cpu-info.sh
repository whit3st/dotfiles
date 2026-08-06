#!/usr/bin/env bash
# Polybar module: CPU load percent + average frequency, combined. No root.
# Output e.g. "CPU 12% | 1.75GHz". Colour #F0C674 matches colors.primary in config.ini.
set -euo pipefail

PREFIX='%{F#F0C674}CPU %{F-}'
SAMPLE_DELAY=0.2

cpu_percent() { # $1 prev "cpu ..." line  $2 curr "cpu ..." line -> integer percent
	awk -v prev="$1" -v curr="$2" '
		BEGIN {
			split(prev, p, " "); split(curr, c, " ")
			pidle = p[5] + p[6]; cidle = c[5] + c[6]
			psum = 0; csum = 0
			for (i = 2; i <= 11; i++) { psum += p[i]+0; csum += c[i]+0 }
			dtotal = csum - psum; didle = cidle - pidle
			if (dtotal <= 0) { print 0; exit }
			printf "%.0f", (dtotal - didle) * 100 / dtotal
		}'
}

avg_ghz() { # $@ scaling_cur_freq values in kHz -> average GHz, 2 decimals (blank if none)
	awk -v vals="$*" '
		BEGIN {
			n = split(vals, a, " ")
			if (n == 0) exit
			for (i = 1; i <= n; i++) sum += a[i]
			printf "%.2f", (sum / n) / 1000000
		}'
}

_main() {
	local prev curr pct freqs ghz

	prev=$(grep '^cpu ' /proc/stat)
	sleep "$SAMPLE_DELAY"
	curr=$(grep '^cpu ' /proc/stat)
	pct=$(cpu_percent "$prev" "$curr")

	freqs=$(cat /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_cur_freq 2>/dev/null || true)
	ghz=$(avg_ghz $freqs)
	[ -z "$ghz" ] && ghz='?'

	printf '%s%s%% | %sGHz\n' "$PREFIX" "$pct" "$ghz"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
	_main
fi
