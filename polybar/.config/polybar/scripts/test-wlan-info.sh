#!/usr/bin/env bash
# Unit test for parse_active_ssid()/last_two_octets() in wlan-info.sh.
# Run: bash test-wlan-info.sh
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./wlan-info.sh
source "$DIR/wlan-info.sh" # defines the helpers; _main is guarded, won't run

fail=0
check() { # $1 expected  $2 actual  $3 label
	if [ "$2" = "$1" ]; then
		echo "ok   - $3"
	else
		echo "FAIL - $3 (want '$1' got '$2')"
		fail=1
	fi
}

check "IDR-5J5P9H4 4269" "$(parse_active_ssid "yes:IDR-5J5P9H4 4269")" "active row => ssid (spaces kept)"
check ""                 "$(parse_active_ssid "no:SomeOtherAP")"       "inactive row => blank"
check ""                 "$(parse_active_ssid "")"                    "empty row => blank"

check "137.150" "$(last_two_octets "192.168.137.150")" "192.168.137.150 => 137.150"
check "0.1"     "$(last_two_octets "10.0.0.1")"        "10.0.0.1 => 0.1"
check ""        "$(last_two_octets "not-an-ip")"       "malformed => blank"

exit "$fail"
