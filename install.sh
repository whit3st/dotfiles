#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[*]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[x]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "Do not run this script as root"
    exit 1
fi

# Official repository packages
PACMAN_PKGS=(
    # Base
    base
    base-devel
    linux
    linux-headers
    linux-firmware
    intel-ucode

    # Shell & Terminal
    zsh
    alacritty
    kitty

    # Window Manager & Desktop
    i3-wm
    i3lock
    i3status
    polybar
    rofi
    dmenu
    picom
    feh
    arandr

    # File Manager
    thunar
    thunar-archive-plugin
    thunar-media-tags-plugin
    thunar-volman
    tumbler

    # Display Manager
    lightdm
    lightdm-gtk-greeter
    ly

    # Audio
    pipewire
    pipewire-alsa
    pipewire-jack
    pipewire-pulse
    wireplumber
    pavucontrol

    # Networking
    networkmanager
    openssh
    bluez
    bluez-utils

    # Graphics & Display
    nvidia-utils
    nvidia-settings
    brightnessctl

    # Fonts
    noto-fonts
    noto-fonts-cjk
    ttf-dejavu
    ttf-jetbrains-mono-nerd
    ttf-liberation
    ttf-roboto
    woff2-font-awesome

    # Development
    git
    vim
    docker
    docker-compose
    gradle
    jdk-openjdk
    mise
    nvm

    # Utilities
    stow
    htop
    tree
    fastfetch
    unzip
    unrar
    ntfs-3g
    xclip
    xdotool
    imagemagick
    img2pdf
    yt-dlp

    # Applications
    firefox
    discord
    mpv
    obs-studio
    flameshot
    mousepad

    # GTK & Theming
    kde-gtk-config
    nwg-look
    gtk-engine-murrine
    breeze-icons
    breeze-gtk
    breeze

    # X11
    xorg-xinit
    xorg-xset
    autorandr
    xorg-xsetroot
    xorg-xrandr
    wmname

    # System
    btrfs-progs
    efibootmgr
    zram-generator
    flatpak
    os-prober
)

# AUR packages (requires yay)
AUR_PKGS=(
    brave-bin
    visual-studio-code-bin
    slack-desktop
    legcord-bin
    alacritty-themes
    spoofdpi
    zapzap
)

install_yay() {
    if ! command -v yay &> /dev/null; then
        print_status "Installing yay..."
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si --noconfirm
        cd -
        rm -rf /tmp/yay
    else
        print_status "yay is already installed"
    fi
}

install_pacman_packages() {
    print_status "Installing official repository packages..."
    sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"
}

install_aur_packages() {
    print_status "Installing AUR packages..."
    yay -S --needed --noconfirm "${AUR_PKGS[@]}"
}

setup_services() {
    print_status "Enabling services..."
    sudo systemctl enable NetworkManager
    sudo systemctl enable bluetooth
    sudo systemctl enable docker
    sudo systemctl enable lightdm

    # Add user to docker group
    sudo usermod -aG docker "$USER"
}

install_oh_my_zsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        print_status "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        print_status "Oh My Zsh is already installed"
    fi
}

stow_dotfiles() {
    print_status "Stowing dotfiles..."
    cd "$(dirname "$0")"
    stow .
}

main() {
    echo "=========================================="
    echo "       Dotfiles Installation Script      "
    echo "=========================================="
    echo ""

    print_warning "This will install packages and configure your system."
    read -p "Continue? [y/N] " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Aborted."
        exit 1
    fi

    print_status "Updating system..."
    sudo pacman -Syu --noconfirm

    install_pacman_packages
    install_yay
    install_aur_packages
    install_oh_my_zsh
    setup_services
    stow_dotfiles

    echo ""
    echo "=========================================="
    print_status "Installation complete!"
    echo "=========================================="
    echo ""
    print_warning "Please reboot your system."
    print_warning "After reboot, run: chsh -s /bin/zsh"
}

main "$@"
