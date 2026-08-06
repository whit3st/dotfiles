#!/usr/bin/env bash
# Unit test for battery_prefix()/watts_from_uw()/power_sign() in battery-power.sh.
# Run: bash test-battery-power.sh
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./battery-power.sh
source "$DIR/battery-power.sh" # defines the helpers; _main is guarded, won't run

fail=0
check() { # $1 expected  $2 actual  $3 label
	if [ "$2" = "$1" ]; then
		echo "ok   - $3"
	else
		echo "FAIL - $3 (want '$1' got '$2')"
		fail=1
	fi
}

check "CHR "  "$(battery_prefix "Charging"    54)" "charging => CHR"
check "FULL " "$(battery_prefix "Full"        99)" "full => FULL"
check "LOW "  "$(battery_prefix "Discharging" 10)" "discharging, 10%%<=15%% => LOW"
check "BAT "  "$(battery_prefix "Discharging" 54)" "discharging, 54%% => BAT"
check "BAT "  "$(battery_prefix "Discharging" "")" "unknown percent => BAT (safe default)"

check "9.8"  "$(watts_from_uw 9800000)"  "9800000uW => 9.8W"
check "0.0"  "$(watts_from_uw 0)"        "0uW => 0.0W"

check "+" "$(power_sign "Charging")"    "charging => +"
check ""  "$(power_sign "Discharging")" "discharging => no sign"

exit "$fail"
