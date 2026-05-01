#!/usr/bin/env bash

set -euo pipefail

ok() {
  printf '[ok] %s\n' "$1"
}

warn() {
  printf '[warn] %s\n' "$1"
}

fail() {
  printf '[x] %s\n' "$1" >&2
  exit 1
}

required_paths=(
  "$HOME/.zshrc"
  "$HOME/.gitconfig"
  "$HOME/.config/i3/config"
  "$HOME/.config/polybar/config.ini"
  "$HOME/.config/alacritty/alacritty.toml"
  "$HOME/.config/picom/picom.conf"
)

for path in "${required_paths[@]}"; do
  if [[ -e "$path" ]]; then
    ok "exists: $path"
  else
    fail "missing required path: $path"
  fi
done

if zsh -n "$HOME/.zshrc"; then
  ok "zsh syntax valid"
else
  fail "zsh syntax check failed"
fi

if command -v i3-msg >/dev/null 2>&1 && pgrep -x i3 >/dev/null 2>&1; then
  if i3-msg reload >/dev/null; then
    ok "i3 reload successful"
  else
    warn "i3 reload failed"
  fi
else
  warn "skipping i3 reload (i3 not running)"
fi

if [[ -x "$HOME/.config/polybar/launch.sh" ]]; then
  ok "polybar launcher executable"
else
  warn "polybar launcher missing or not executable"
fi

local_identity="$HOME/.gitconfig.local"
if [[ -f "$local_identity" ]]; then
  ok "local git identity found"
else
  warn "missing local git identity: $local_identity"
fi

ok "dotfiles check complete"
