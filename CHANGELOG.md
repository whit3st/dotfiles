# Changelog

## 2026-07-14

### Added
- polybar: live power-draw module (`PWR`, watts read from `/sys`, `+` prefix while charging) and current refresh-rate module (`REF`, eDP Hz, updated instantly via IPC)
- i3 + scripts: Copilot key (`Super+Shift+F23`) toggles the internal panel between 60/120 Hz to save battery — `polybar/scripts/{toggle-refresh,refresh-rate,power-draw}.sh` plus `test-refresh-toggle.sh` unit test
- Bluetooth: blueman applet (i3 autostart) and `blueman` package (install.sh, packages.sh)

## 2026-07-10

### Machine-agnostic (multi-computer support)
- lib/detect.sh: hardware detection — GPU vendors, CPU vendor, laptop, microcode pkg, GPU driver pkgs — plus dtf_machine() which keys off DMI board_name (hostname-independent; the machines can all share a hostname). lib/detect.test.sh smoke-tests it.
- hosts/<board-name>/host.env: per-machine overrides for non-detectable values (e.g. hosts/um5606wa/host.env sets DPI=144). Optional friendly-name override via ~/.config/dtf/machine.
- scripts/dtf-display.sh: set every output to its max refresh rate + apply this host's DPI via Xft.dpi — works on the 240/120/60 Hz machines with no config.
- packages.sh / install.sh: GPU drivers + microcode now auto-selected from detected hardware (add_hardware_packages uses detect.sh), instead of hardcoding ucode + nvidia only.
- polybar dpi and x11/.Xresources no longer hardcode 144: polybar reads ${xrdb:Xft.dpi}, .Xresources is a neutral 96 baseline overridden per-host at login.
- autorandr profiles gitignored (per-machine EDID); dropped the tracked home profile.

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
