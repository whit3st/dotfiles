.PHONY: help check bootstrap packages-core packages-desktop services stow-core stow-desktop stow-all unstow-desktop

help:
	@printf "Available targets:\n"
	@printf "  make check            - Run dotfiles sanity checks\n"
	@printf "  make bootstrap        - Install bootstrap prerequisites\n"
	@printf "  make packages-core    - Install core package profile\n"
	@printf "  make packages-desktop - Install core+desktop+dev packages\n"
	@printf "  make services         - Enable default services\n"
	@printf "  make stow-core        - Stow core configs (zsh/git)\n"
	@printf "  make stow-desktop     - Stow desktop-related packages\n"
	@printf "  make stow-all         - Stow full package set\n"
	@printf "  make unstow-desktop   - Unstow desktop-related packages\n"

check:
	./check.sh

bootstrap:
	./bootstrap.sh

packages-core:
	./packages.sh --profiles core

packages-desktop:
	./packages.sh --profiles core,desktop,dev --with-hardware --with-aur

services:
	./services.sh --display-manager ly --add-docker-group

stow-core:
	stow zsh git

stow-desktop:
	stow i3 polybar alacritty picom rofi gtk x11 scripts autorandr pipewire fontconfig theme wallpapers

stow-all:
	stow zsh git i3 polybar alacritty picom rofi gtk x11 scripts autorandr pipewire fontconfig theme wallpapers --adopt

unstow-desktop:
	stow -D i3 polybar alacritty picom rofi gtk x11 scripts autorandr pipewire fontconfig theme wallpapers
