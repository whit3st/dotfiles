#!/usr/bin/env bash

set -euo pipefail

if [[ ${EUID} -eq 0 ]]; then
  printf '[x] Do not run as root\n' >&2
  exit 1
fi

printf '[*] Installing bootstrap prerequisites...\n'
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm git stow zsh curl base-devel

printf '[*] Bootstrap complete.\n'
