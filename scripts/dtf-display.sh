#!/bin/sh
# Machine-agnostic display setup, run from i3 (exec_always):
#   1. set every connected output to its MAX refresh rate at native resolution
#   2. apply this host's DPI (hosts/<hostname>/host.env, default 96) via xrdb
# Nothing here is hardcoded to one machine — works on the 240/120/60 Hz boxes alike.
# Stowed to ~/dtf-display.sh; it finds the repo via its own symlink target.

self=$(readlink -f "$0" 2>/dev/null || echo "$0")
repo=$(cd "$(dirname "$self")/.." 2>/dev/null && pwd)   # scripts/ -> repo root
# Machine key comes from the detection lib (DMI board name), NOT hostname.
[ -n "$repo" ] && [ -r "$repo/lib/detect.sh" ] && . "$repo/lib/detect.sh"
if command -v dtf_machine >/dev/null 2>&1; then machine=$(dtf_machine); else
  machine=$(cat /sys/class/dmi/id/board_name 2>/dev/null | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9-')
fi

# 1) Max refresh per connected output. The first indented mode line xrandr prints
#    for an output is its highest/native resolution; pick the highest rate there.
xrandr --query 2>/dev/null | awk '
  / connected/ { out=$1; seen=0; next }
  /^[ \t]/ && !seen && out != "" {
    res=$1; best=0
    for (i=2; i<=NF; i++) { r=$i; gsub(/[*+]/,"",r); if (r+0 > best) best=r }
    print out, res, best; seen=1
  }' | while read -r out res rate; do
    xrandr --output "$out" --mode "$res" --rate "$rate" 2>/dev/null
  done

# 2) Per-host DPI (default 96 if this host has no host.env).
DPI=96
[ -n "$repo" ] && [ -n "$machine" ] && [ -f "$repo/hosts/$machine/host.env" ] && . "$repo/hosts/$machine/host.env"
printf 'Xft.dpi: %s\n' "$DPI" | xrdb -merge 2>/dev/null
