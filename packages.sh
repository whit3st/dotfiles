#!/usr/bin/env bash

set -euo pipefail

if [[ ${EUID} -eq 0 ]]; then
  printf '[x] Do not run as root\n' >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/detect.sh
. "${SCRIPT_DIR}/lib/detect.sh"

CORE_PKGS=(
  git stow zsh vim fastfetch htop tree unzip unrar ntfs-3g
  openssh networkmanager bluez bluez-utils
)

DESKTOP_PKGS=(
  i3-wm i3lock i3status polybar rofi dmenu picom feh arandr ly
  thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman tumbler
  alacritty kitty flameshot mousepad
  xorg-server xf86-input-libinput xorg-xkbcomp xorg-setxkbmap
  xorg-xinit xorg-xset xorg-xsetroot xorg-xrandr xorg-xinput wmname
  autorandr xclip xdotool brightnessctl
  pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber pavucontrol
  noto-fonts noto-fonts-cjk ttf-dejavu ttf-jetbrains-mono-nerd ttf-liberation ttf-roboto
  woff2-font-awesome
  breeze-icons breeze-gtk breeze kde-gtk-config nwg-look
)

DEV_PKGS=(
  docker docker-compose gradle jdk-openjdk mise nvm
)

MEDIA_PKGS=(
  firefox mpv obs-studio imagemagick img2pdf yt-dlp
)

SYSTEM_PKGS=(
  btrfs-progs efibootmgr zram-generator flatpak os-prober pciutils
)

AUR_PKGS=(
  brave-bin visual-studio-code-bin slack-desktop legcord-bin alacritty-themes spoofdpi zapzap
  gtk-engine-murrine  # moved from official repos to AUR
  asusctl             # ASUS laptop control: battery charge limit, kbd backlight, power profiles
)

usage() {
  cat <<'EOF'
Usage: ./packages.sh [options]

Options:
  --profiles <list>    Comma-separated profiles: core,desktop,dev,media,system
  --with-aur           Install AUR package set via yay
  --with-hardware      Add detected microcode/GPU packages
  --help               Show this help

Example:
  ./packages.sh --profiles core,desktop,dev --with-hardware --with-aur
EOF
}

install_yay() {
  if command -v yay >/dev/null 2>&1; then
    return
  fi

  printf '[*] Installing yay...\n'
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  pushd /tmp/yay >/dev/null
  makepkg -si --noconfirm
  popd >/dev/null
  rm -rf /tmp/yay
}

add_hardware_packages() {
  # Microcode for the detected CPU.
  local ucode
  ucode="$(dtf_ucode_pkg)"
  [[ -n "${ucode}" ]] && SELECTED_PKGS+=("${ucode}")

  # Userspace GPU drivers for every detected GPU (amd/intel/nvidia, incl. hybrid).
  local -a gpu
  read -r -a gpu <<< "$(dtf_gpu_pkgs)"
  [[ ${#gpu[@]} -gt 0 ]] && SELECTED_PKGS+=("${gpu[@]}")
}

PROFILE_LIST="core"
WITH_AUR=false
WITH_HARDWARE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profiles)
      PROFILE_LIST="${2:-}"
      shift 2
      ;;
    --with-aur)
      WITH_AUR=true
      shift
      ;;
    --with-hardware)
      WITH_HARDWARE=true
      shift
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      printf '[x] Unknown option: %s\n' "$1" >&2
      usage
      exit 1
      ;;
  esac
done

IFS=',' read -r -a profiles <<< "${PROFILE_LIST}"
SELECTED_PKGS=()

for profile in "${profiles[@]}"; do
  case "${profile}" in
    core) SELECTED_PKGS+=("${CORE_PKGS[@]}") ;;
    desktop) SELECTED_PKGS+=("${DESKTOP_PKGS[@]}") ;;
    dev) SELECTED_PKGS+=("${DEV_PKGS[@]}") ;;
    media) SELECTED_PKGS+=("${MEDIA_PKGS[@]}") ;;
    system) SELECTED_PKGS+=("${SYSTEM_PKGS[@]}") ;;
    *)
      printf '[x] Unknown profile: %s\n' "${profile}" >&2
      exit 1
      ;;
  esac
done

if [[ "${WITH_HARDWARE}" == true ]]; then
  add_hardware_packages
fi

printf '[*] Installing selected pacman packages...\n'
sudo pacman -S --needed --noconfirm "${SELECTED_PKGS[@]}"

if [[ "${WITH_AUR}" == true ]]; then
  install_yay
  printf '[*] Installing selected AUR packages...\n'
  yay -S --needed --noconfirm "${AUR_PKGS[@]}"
fi

printf '[*] Package installation complete.\n'
