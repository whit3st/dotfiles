#!/usr/bin/env bash
# lib/detect.sh — hardware detection helpers for machine-agnostic dotfiles.
# Source it, then call the functions. All are read-only / side-effect free.
#
#   . "$(dirname "$0")/lib/detect.sh"
#   for g in $(dtf_gpu_vendors); do ...; done
#
# This is the core of the "detect + host-profiles" model: anything derivable
# from the hardware is detected here (GPU/CPU/laptop); anything subjective or
# non-detectable lives per-machine in hosts/<hostname>/host.env.

# Short hostname (unreliable as a machine key — may be identical across machines).
dtf_hostname() { hostname -s 2>/dev/null || cat /proc/sys/kernel/hostname; }

# Stable per-machine key that names hosts/<key>/. Hostname is NOT used as the
# primary because these machines can all share one hostname. Resolution order:
#   1. explicit override in ~/.config/dtf/machine (friendly names you choose)
#   2. DMI board name   (e.g. UM5606WA -> um5606wa)  -- auto, unique per model
#   3. DMI product name (fallback)
#   4. hostname         (last resort)
dtf_machine() {
  if [ -r "${HOME}/.config/dtf/machine" ]; then
    sed 's/#.*//' "${HOME}/.config/dtf/machine" | tr -d '[:space:]' | grep -m1 . && return
  fi
  _dtf_raw=$(cat /sys/class/dmi/id/board_name 2>/dev/null)
  [ -z "${_dtf_raw}" ] && _dtf_raw=$(cat /sys/class/dmi/id/product_name 2>/dev/null)
  [ -z "${_dtf_raw}" ] && _dtf_raw=$(dtf_hostname)
  printf '%s' "${_dtf_raw}" | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9-'
}

# CPU vendor: amd | intel | unknown
dtf_cpu_vendor() {
  case "$(awk -F': ' '/vendor_id/{print $2; exit}' /proc/cpuinfo 2>/dev/null)" in
    *AuthenticAMD*) echo amd ;;
    *GenuineIntel*) echo intel ;;
    *) echo unknown ;;
  esac
}

# GPU vendors, one per line (may be several on hybrid): amd / intel / nvidia
dtf_gpu_vendors() {
  lspci -mm 2>/dev/null | awk -F'"' '$2 ~ /VGA|3D|Display/ {print $4}' | while read -r v; do
    case "$v" in
      *AMD*|*ATI*|*"Advanced Micro"*) echo amd ;;
      *Intel*)                        echo intel ;;
      *NVIDIA*|*nVidia*)              echo nvidia ;;
    esac
  done | sort -u
}

# True (0) if this machine has a battery (i.e. is a laptop).
dtf_is_laptop() {
  for b in /sys/class/power_supply/BAT*; do [ -e "$b" ] && return 0; done
  return 1
}

# Microcode package for this CPU (empty if unknown).
dtf_ucode_pkg() {
  case "$(dtf_cpu_vendor)" in
    amd)   echo amd-ucode ;;
    intel) echo intel-ucode ;;
  esac
}

# Userspace GPU driver packages for every detected GPU (deduped, space-separated).
dtf_gpu_pkgs() {
  for g in $(dtf_gpu_vendors); do
    case "$g" in
      amd)    echo "mesa vulkan-radeon libva-mesa-driver" ;;
      intel)  echo "mesa vulkan-intel intel-media-driver" ;;
      nvidia) echo "nvidia nvidia-utils nvidia-settings nvidia-prime" ;;
    esac
  done | tr ' ' '\n' | sed '/^$/d' | sort -u | tr '\n' ' '
}
