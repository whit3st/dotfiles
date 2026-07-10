#!/usr/bin/env bash

set -euo pipefail

if [[ ${EUID} -eq 0 ]]; then
  printf '[x] Do not run as root\n' >&2
  exit 1
fi

DISPLAY_MANAGER="lightdm"
ADD_DOCKER_GROUP=false

usage() {
  cat <<'EOF'
Usage: ./services.sh [options]

Options:
  --display-manager <lightdm|ly|none>
  --add-docker-group
  --help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --display-manager)
      DISPLAY_MANAGER="${2:-}"
      shift 2
      ;;
    --add-docker-group)
      ADD_DOCKER_GROUP=true
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

printf '[*] Enabling base services...\n'
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth

if systemctl list-unit-files | grep -q '^docker\.service'; then
  sudo systemctl enable docker
fi

if systemctl list-unit-files | grep -q '^asusd\.service'; then
  sudo systemctl enable asusd
fi

case "${DISPLAY_MANAGER}" in
  lightdm)
    sudo systemctl enable lightdm
    ;;
  ly)
    sudo systemctl enable ly
    ;;
  none)
    printf '[*] Skipping display manager enablement.\n'
    ;;
  *)
    printf '[x] Invalid display manager: %s\n' "${DISPLAY_MANAGER}" >&2
    exit 1
    ;;
esac

if [[ "${ADD_DOCKER_GROUP}" == true ]]; then
  sudo usermod -aG docker "$USER"
fi

printf '[*] Service setup complete.\n'
