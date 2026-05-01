# Dotfiles

Modular GNU Stow dotfiles for Arch Linux (i3 + polybar + alacritty + picom).

## Fresh Install

```bash
# 1. Install git and stow
sudo pacman -S git stow

# 2. Clone
cd ~
git clone git@github.com:USERNAME/dotfiles.git

# 3. Run install script (installs packages, yay, oh-my-zsh, enables services)
cd dotfiles
./install.sh

# 4. Stow selected packages
stow zsh git i3 polybar alacritty picom rofi gtk x11 scripts autorandr pipewire fontconfig theme wallpapers

# 4.1 Set your git identity
cp .gitconfig.local.example ~/.gitconfig.local
# edit ~/.gitconfig.local with your name/email

# 4.2 Optional local shell overrides
cp .zshrc.local.example ~/.zshrc.local
# add machine-specific aliases/env vars to ~/.zshrc.local

# 4.3 Optional local i3 overrides
cp .config/i3/local.conf.example ~/.config/i3/local.conf

# 5. Reboot
reboot
```

## Post-reboot

```bash
# Set zsh as default shell
chsh -s /bin/zsh

# Generate SSH keys
ssh-keygen -t ed25519 -C "your@email.com"
cat ~/.ssh/id_ed25519.pub
# Add to GitHub/GitLab

# If display profile doesn't auto-apply, save new one
autorandr --save home
```

## Stow Packages

| Package | Description |
|--------|-------------|
| `zsh` | Shell config (`~/.zshrc`) |
| `git` | Git config and local identity template |
| `i3` | i3 window manager config |
| `polybar` | Polybar config and launcher |
| `alacritty` | Terminal config |
| `picom` | Compositor config |
| `rofi` | Launcher config |
| `gtk` | GTK 2/3/4 settings |
| `fontconfig` | Font config and local fonts |
| `autorandr` | Display profiles |
| `pipewire` | Audio tuning snippets |
| `x11` | X11 startup resources |
| `scripts` | Helper scripts (night mode) |
| `theme` | Orchis theme files |
| `wallpapers` | Wallpapers |

## Minimal Stow Example

```bash
stow zsh git i3 polybar alacritty picom rofi
```

## Keybinds

| Key | Action |
|-----|--------|
| `Mod+Return` | Terminal |
| `Mod+d` | Rofi |
| `Mod+Shift+q` | Kill window |
| `Mod+1-0` | Switch workspace |
| `Mod+Shift+1-0` | Move to workspace |
| `Mod+Shift+n` | Night mode on |
| `Mod+Ctrl+n` | Night mode off |
| `Print` | Screenshot (flameshot) |

## Notes

- Mod key is Super (Windows key)
- Display manager: lightdm
- Monitor config saved in `~/.config/autorandr/home/`
