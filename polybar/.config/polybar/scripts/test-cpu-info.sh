#!/usr/bin/env bash
# Unit test for cpu_percent()/avg_ghz() in cpu-info.sh. Run: bash test-cpu-info.sh
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./cpu-info.sh
source "$DIR/cpu-info.sh" # defines cpu_percent()/avg_ghz(); _main is guarded, won't run

fail=0
check() { # $1 expected  $2 actual  $3 label
	if [ "$2" = "$1" ]; then
		echo "ok   - $3"
	else
		echo "FAIL - $3 (want '$1' got '$2')"
		fail=1
	fi
}

PREV="cpu 100 0 100 800 0 0 0 0 0 0"
CURR="cpu 200 0 200 900 0 0 0 0 0 0"
check 67 "$(cpu_percent "$PREV" "$CURR")" "1000->1300 total, 800->900 idle => 67%"
check 0  "$(cpu_percent "$PREV" "$PREV")" "identical snapshots => 0%"

check "2.00" "$(avg_ghz 1800000 2200000)" "1.8GHz + 2.2GHz => avg 2.00GHz"
check "1.50" "$(avg_ghz 1500000)"         "single core => itself"
check ""     "$(avg_ghz)"                 "no readings => blank"

exit "$fail"
