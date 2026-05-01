# Dotfiles

i3 + polybar + alacritty + picom on Arch

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

# 4. Stow
stow .

# 4.1 Set your git identity
cp .gitconfig.local.example ~/.gitconfig.local
# edit ~/.gitconfig.local with your name/email

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

## What's Included

| Config | Description |
|--------|-------------|
| i3 | Window manager |
| polybar | Status bar |
| alacritty | Terminal |
| picom | Compositor (blur, shadows, rounded corners) |
| rofi | App launcher |
| autorandr | Display profiles (240Hz) |
| gtk-3.0/4.0 | GTK theme settings |
| .themes | Orchis theme |
| fonts | JetBrains Mono, Iosevka, Icomoon |
| wallpapers | Wallpaper |

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
