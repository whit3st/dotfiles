#!/usr/bin/env bash

set -euo pipefail

if [[ ${EUID} -eq 0 ]]; then
  printf '[x] Do not run as root\n' >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/detect.sh
. "${SCRIPT_DIR}/lib/detect.sh"

PACMAN_PKGS=(
  # Base
  base base-devel linux linux-headers linux-firmware

  # Shell & Terminal
  zsh alacritty kitty ghostty

  # Window Manager & Desktop
  i3-wm i3lock i3status polybar rofi dmenu picom feh arandr

  # File Manager
  thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman tumbler

  # Display Manager
  ly

  # Audio
  pipewire pipewire-alsa pipewire-jack pipewire-pulse wireplumber pavucontrol

  # Networking
  networkmanager openssh bluez bluez-utils blueman

  # Graphics & Display
  brightnessctl

  # Fonts
  noto-fonts noto-fonts-cjk ttf-dejavu ttf-jetbrains-mono-nerd ttf-liberation ttf-roboto woff2-font-awesome

  # Development
  git vim docker docker-compose gradle jdk-openjdk pciutils
  neovim fd fzf ripgrep tree-sitter-cli

  # Utilities
  stow htop tree fastfetch unzip unrar ntfs-3g xclip xdotool imagemagick img2pdf yt-dlp

  # Applications
  firefox discord mpv obs-studio flameshot mousepad

  # GTK & Theming
  kde-gtk-config nwg-look breeze-icons breeze-gtk breeze

  # X11
  xorg-server xf86-input-libinput xorg-xkbcomp xorg-setxkbmap
  xorg-xinit xorg-xset xorg-xsetroot xorg-xrandr xorg-xinput autorandr wmname

  # System
  btrfs-progs efibootmgr zram-generator flatpak os-prober
)

AUR_PKGS=(
  brave-bin visual-studio-code-bin slack-desktop legcord-bin alacritty-themes spoofdpi zapzap
  gtk-engine-murrine  # moved from official repos to AUR
  asusctl             # ASUS laptop control: battery charge limit, kbd backlight, power profiles
)

print_status() { printf '[*] %s\n' "$1"; }
print_error()  { printf '[x] %s\n' "$1" >&2; }

install_yay() {
  if command -v yay &>/dev/null; then
    print_status "yay already installed"
    return
  fi
  print_status "Installing yay..."
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
  rm -rf /tmp/yay
}

add_hardware_packages() {
  local ucode
  ucode="$(dtf_ucode_pkg)"
  [[ -n "$ucode" ]] && PACMAN_PKGS+=("$ucode")

  local -a gpu
  read -r -a gpu <<< "$(dtf_gpu_pkgs)"
  [[ ${#gpu[@]} -gt 0 ]] && PACMAN_PKGS+=("${gpu[@]}")
}

setup_services() {
  print_status "Enabling services..."
  sudo systemctl enable NetworkManager
  sudo systemctl enable bluetooth
  sudo systemctl enable docker 2>/dev/null || true
  sudo systemctl enable asusd 2>/dev/null || true
  sudo systemctl enable ly@tty2.service
  sudo usermod -aG docker "$USER"
}

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    print_status "Oh My Zsh already installed"
    return
  fi
  print_status "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

install_herdr() {
  if command -v herdr &>/dev/null; then
    print_status "herdr already installed"
    return
  fi
  print_status "Installing herdr..."
  sh -c "$(curl -fsSL https://herdr.dev/install.sh)"
}

stow_dotfiles() {
  print_status "Stowing dotfiles..."
  cd "$SCRIPT_DIR"
  stow zsh git i3 polybar alacritty ghostty picom rofi gtk x11 scripts autorandr pipewire fontconfig theme wallpapers nvim herdr helpers
}

ensure_local_config() {
  if [[ ! -f "$HOME/.gitconfig.local" ]]; then
    cp "$SCRIPT_DIR/git/.gitconfig.local.example" "$HOME/.gitconfig.local"
    print_status "Created ~/.gitconfig.local — edit it with your name/email"
  fi
  if [[ ! -f "$HOME/.zshrc.local" ]]; then
    cp "$SCRIPT_DIR/zsh/.zshrc.local.example" "$HOME/.zshrc.local"
    print_status "Created ~/.zshrc.local"
  fi
  if [[ ! -f "$HOME/.helpers/scratchpad.md" ]]; then
    mkdir -p "$HOME/.helpers"
    touch "$HOME/.helpers/scratchpad.md"
    print_status "Created ~/.helpers/scratchpad.md"
  fi
}

main() {
  printf '==========================================\n'
  printf '       Dotfiles Installation Script      \n'
  printf '==========================================\n\n'

  print_status "Updating system..."
  sudo pacman -Syu --noconfirm

  add_hardware_packages

  print_status "Installing packages..."
  sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"

  install_yay

  print_status "Installing AUR packages..."
  yay -S --needed --noconfirm "${AUR_PKGS[@]}"

  install_oh_my_zsh
  install_herdr
  setup_services
  stow_dotfiles
  ensure_local_config

  print_status "Pre-seeding Neovim plugins..."
  if command -v nvim >/dev/null 2>&1; then nvim --headless "+Lazy! sync" +qa || print_status "warning: nvim plugin sync failed, will retry on first launch"; fi

  # Deploy system-level files (e.g. /etc/X11/xorg.conf.d touchpad tap-to-click).
  # The system/ tree mirrors absolute paths and is copied, not stowed.
  if [[ -d "$SCRIPT_DIR/system" ]]; then
    print_status "Installing system files to /etc..."
    ( cd "$SCRIPT_DIR/system" && find . -type f -print0 | while IFS= read -r -d '' f; do
        sudo install -Dm644 "$f" "/${f#./}"
      done )
  fi

  printf '\n==========================================\n'
  print_status "Installation complete!"
  printf '==========================================\n\n'
  printf '[!] Please reboot your system.\n'
  printf '[!] After reboot, run: chsh -s /bin/zsh\n'
}

main "$@"
