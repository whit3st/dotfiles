#!/usr/bin/env bash

set -euo pipefail

usage() {
    printf 'Usage: %s [on|off]\n' "$(basename "$0")"
}

if [[ $# -ne 1 ]]; then
    usage
    exit 1
fi

case "$1" in
    on)
        gamma='1.0:0.8:0.6'
        message='Blue light filter active.'
        ;;
    off)
        gamma='1.0:1.0:1.0'
        message='Blue light filter disabled.'
        ;;
    *)
        usage
        exit 1
        ;;
esac

mapfile -t monitors < <(xrandr --query | awk '$2 == "connected" {print $1}')

if [[ ${#monitors[@]} -eq 0 ]]; then
    printf 'No connected monitors detected.\n' >&2
    exit 1
fi

for monitor in "${monitors[@]}"; do
    xrandr --output "$monitor" --gamma "$gamma"
done

printf '%s\n' "$message"
