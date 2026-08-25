#!/bin/bash
# SemperFix-OMP WSL loader

WIN_USER=$(cmd.exe /c "echo %USERNAME%" | tr -d '\r')
WIN_HOME="/mnt/c/Users/$WIN_USER"
WIN_THEME_DIR="$WIN_HOME/AppData/Local/Programs/oh-my-posh/themes"
WSL_THEME_DIR="$HOME/.poshthemes"
SYNC_FILE="$WIN_HOME/.poshtheme"

# Symlink theme directory
if [ ! -d "$WSL_THEME_DIR" ]; then
    ln -s "$WIN_THEME_DIR" "$WSL_THEME_DIR"
fi

# Load theme from sync file
if [ -f "$SYNC_FILE" ]; then
    THEME_NAME=$(cat "$SYNC_FILE")
    THEME_PATH="$WSL_THEME_DIR/$THEME_NAME"

    if [ -f "$THEME_PATH" ]; then
        eval "$(oh-my-posh init bash --config "$THEME_PATH")"
    fi
fi
