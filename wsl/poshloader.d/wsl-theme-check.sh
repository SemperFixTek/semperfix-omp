#!/usr/bin/env bash
echo "WSL Theme Diagnostics"
echo "----------------------"

POSH_THEMES_PATH="$HOME/.poshthemes"
SHARED_THEME_FILE="/mnt/c/Users/sfx/.poshtheme"

echo "POSH_THEMES_PATH: $POSH_THEMES_PATH"
echo "SHARED_THEME_FILE: $SHARED_THEME_FILE"
echo

echo "Listing themes:"
ls "$POSH_THEMES_PATH" 2>/dev/null || echo "❌ Cannot list $POSH_THEMES_PATH"

if [ -f "$SHARED_THEME_FILE" ]; then
    echo "Shared theme file contents:"
    cat "$SHARED_THEME_FILE"
else
    echo "❌ Shared theme file not found."
fi
