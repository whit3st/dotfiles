# Changelog

## 2026-07-10

### Added
- i3: screen brightness keybindings (XF86MonBrightness*) via brightnessctl
- polybar: battery module (BAT0/AC0) and explicit DPI (144)
- HiDPI: Xft.dpi set to 144 for the 2880x1800 panel
- Touchpad: libinput tap-to-click rule (system/etc/X11/xorg.conf.d/30-touchpad.conf); install.sh now deploys the system/ tree to /etc
- Packages: xorg-xinput; asusctl (AUR) for battery charge limit / keyboard backlight / power profiles
- services.sh + install.sh: enable asusd when present

### Changed
- i3: volume step 10% -> 5%
- packages.sh / install.sh: move gtk-engine-murrine to the AUR list (dropped from official repos)
- Display manager: switch default from lightdm to ly (ly@tty2) across services.sh, install.sh, packages.sh, Makefile; lightdm no longer installed by default

### Fixed
- zsh: mise activation errored on missing ~/.local/bin/mise; now resolves mise from PATH and guards if absent
- git: remove stray `name` key from the [include] section of git/.gitconfig
- touchpad: enable tap-to-click from the i3 config (exec_always xinput) so it survives reboot without a root xorg.conf.d file
- packages/install: declare xorg-server, xf86-input-libinput, xorg-xkbcomp, xorg-setxkbmap explicitly so the X server isn't orphan-removed when a display manager is uninstalled
