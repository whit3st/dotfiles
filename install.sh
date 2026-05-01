#!/usr/bin/env bash

set -euo pipefail

if [[ ${EUID} -eq 0 ]]; then
  printf '[x] Do not run as root\n' >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

printf '==========================================\n'
printf '      Dotfiles Installation (Modular)    \n'
printf '==========================================\n\n'

printf '[*] Running bootstrap...\n'
"${SCRIPT_DIR}/bootstrap.sh"

printf '[*] Installing default package profiles: core,desktop,dev\n'
"${SCRIPT_DIR}/packages.sh" --profiles core,desktop,dev --with-hardware --with-aur

printf '[*] Enabling default services...\n'
"${SCRIPT_DIR}/services.sh" --display-manager lightdm --add-docker-group

printf '[*] Installing Oh My Zsh (if missing)...\n'
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

printf '[*] Stowing modular packages...\n'
stow zsh git i3 polybar alacritty picom rofi gtk x11 scripts autorandr pipewire fontconfig theme wallpapers

printf '\n==========================================\n'
printf '[*] Installation complete.\n'
printf '==========================================\n\n'
printf '[!] Reboot recommended.\n'
printf '[!] After reboot, run: chsh -s /bin/zsh\n'
