#!/usr/bin/env bash
# Global persistent scratchpad - opens markdown file in nvim popup.
# File: ~/.helpers/scratchpad.md

SCRATCHPAD_FILE="$HOME/.helpers/scratchpad.md"

# Create file if doesn't exist
if [ ! -f "$SCRATCHPAD_FILE" ]; then
    touch "$SCRATCHPAD_FILE"
fi

# Open nvim in popup with the scratchpad file
tmux popup -d "$HOME" -xC -yC -w80% -h80% -E "nvim '$SCRATCHPAD_FILE'"
