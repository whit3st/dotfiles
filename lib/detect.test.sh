#!/usr/bin/env bash
# Smoke tests for lib/detect.sh — each helper must return something sane on any
# machine. Run: ./lib/detect.test.sh   (exit 0 = pass)
set -u
dir="$(cd "$(dirname "$0")" && pwd)"
. "$dir/detect.sh"

fail=0
check() { if eval "$2"; then printf '  ok:   %s\n' "$1"; else printf '  FAIL: %s\n' "$1"; fail=1; fi; }

check "hostname is non-empty"        '[ -n "$(dtf_hostname)" ]'
check "machine key non-empty, safe chars" 'm=$(dtf_machine); [ -n "$m" ] && ! echo "$m" | grep -q "[^a-z0-9-]"'
check "cpu vendor is amd|intel|unknown" 'case "$(dtf_cpu_vendor)" in amd|intel|unknown) true;; *) false;; esac'
check "gpu vendors are all valid tokens" 'for g in $(dtf_gpu_vendors); do case "$g" in amd|intel|nvidia) ;; *) exit 1;; esac; done'
check "ucode pkg is amd-ucode|intel-ucode|empty" 'case "$(dtf_ucode_pkg)" in amd-ucode|intel-ucode|"") true;; *) false;; esac'
check "is_laptop exits 0 or 1"       'dtf_is_laptop; r=$?; [ "$r" -eq 0 ] || [ "$r" -eq 1 ]'
check "gpu_pkgs contains mesa when a GPU is present" '[ -z "$(dtf_gpu_vendors)" ] || echo "$(dtf_gpu_pkgs)" | grep -q mesa'

if [ "$fail" -eq 0 ]; then echo "detect.sh: all tests passed"; else echo "detect.sh: FAILURES"; fi
exit "$fail"
