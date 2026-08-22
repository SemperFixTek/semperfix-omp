#!/usr/bin/env bash
# SemperFix-OMP WSL Loader (Instant Apply)

SHARED_THEME_FILE="$(wslpath "$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')")/.poshtheme"
WIN_THEMES="$(wslpath "$(cmd.exe /c 'echo %LOCALAPPDATA%' 2>/dev/null | tr -d '\r')")/Programs/oh-my-posh/themes"

# Read theme
if [ -f "$SHARED_THEME_FILE" ]; then
    theme="$(head -n 1 "$SHARED_THEME_FILE" | tr -d '\r' | xargs)"
else
    theme="paradox.omp.json"
fi

# Initialize OMP
apply_theme() {
    eval "$(oh-my-posh init bash --config "$WIN_THEMES/$theme")"
}

apply_theme

# Change theme from WSL
set_posh_theme() {
    echo "$1" > "$SHARED_THEME_FILE"
    theme="$1"
    apply_theme
    echo "Theme switched to: $1"
}

sync_fonts() {
    echo "[SemperFix] Syncing fonts from Windows..."

    WIN_FONT_DIR=$(wslpath "$(cmd.exe /c 'echo %WINDIR%' | tr -d '\r')")/Fonts
    WSL_FONT_DIR="$HOME/.local/share/fonts"

    mkdir -p "$WSL_FONT_DIR"

    cp "$WIN_FONT_DIR"/JetBrainsMono* "$WSL_FONT_DIR" 2>/dev/null

    fc-cache -f "$WSL_FONT_DIR"

    echo "[SemperFix] WSL font sync complete."
}
