#!/usr/bin/env bash
# Unit test for next_rate() in toggle-refresh.sh. Run: bash test-refresh-toggle.sh
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./toggle-refresh.sh
source "$DIR/toggle-refresh.sh" # defines next_rate(); _main is guarded, won't run

fail=0
check() { # $1 expected  $2 actual  $3 label
	if [ "$2" = "$1" ]; then
		echo "ok   - $3"
	else
		echo "FAIL - $3 (want '$1' got '$2')"
		fail=1
	fi
}

check 60  "$(next_rate 120.00)" "120.00 -> 60"
check 60  "$(next_rate 120)"    "120 -> 60"
check 120 "$(next_rate 60.00)"  "60.00 -> 120"
check 120 "$(next_rate 60)"     "60 -> 120"
check 120 "$(next_rate '?')"    "unknown -> 120 (safe default)"
check 120 "$(next_rate '')"     "empty -> 120 (safe default)"

exit "$fail"
