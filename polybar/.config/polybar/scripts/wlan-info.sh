#!/usr/bin/env bash
# Polybar module: Wi-Fi SSID + last two IP octets, combined. Uses nmcli (iwgetid
# fails outright on this machine's mt7925 driver). No root.
# Output e.g. "IDR-5J5P9H4 4269 137.150"; disconnected shows "wlan0 disconnected".
set -euo pipefail

parse_active_ssid() { # $1 one line of `nmcli -t -f active,ssid dev wifi` -> ssid, or blank if not the active row
	case "$1" in
		yes:*) echo "${1#yes:}" ;;
		*) echo "" ;;
	esac
}

last_two_octets() { # $1 IPv4 address -> "third.fourth" (blank if malformed)
	awk -F. 'NF==4{print $3"."$4}' <<< "$1"
}

wifi_device() { # -> first wifi-type network device name, connected or not (blank if none)
	nmcli -t -f DEVICE,TYPE dev status 2>/dev/null | awk -F: '$2=="wifi"{print $1; exit}'
}

_main() {
	local dev ssid ip octets line

	dev=$(wifi_device)
	if [ -z "$dev" ]; then
		printf 'wlan disconnected\n'
		return
	fi

	ssid=""
	while IFS= read -r line; do
		ssid=$(parse_active_ssid "$line")
		[ -n "$ssid" ] && break
	done <<< "$(nmcli -t -f active,ssid dev wifi 2>/dev/null)"

	if [ -z "$ssid" ]; then
		printf '%%{F#F0C674}%s%%{F#707880} disconnected%%{F-}\n' "$dev"
		return
	fi

	ip=$(ip -4 -o addr show "$dev" 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -1)
	octets=$(last_two_octets "$ip")

	if [ -z "$octets" ]; then
		printf '%%{F#F0C674}%s%%{F-}\n' "$ssid"
	else
		printf '%%{F#F0C674}%s%%{F-} %s\n' "$ssid" "$octets"
	fi
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
	_main
fi
