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

### Fixed
- zsh: mise activation errored on missing ~/.local/bin/mise; now resolves mise from PATH and guards if absent
