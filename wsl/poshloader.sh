###############################################
# SemperFix OMP WSL Loader (Final Release)
# Windows + WSL · Cross-System Theme + Font Sync
###############################################

# Ensure Windows interop paths exist
export PATH="$PATH:/mnt/c/Windows/System32:/mnt/c/Windows"

###############################################
# Shared Paths
###############################################

# Shared theme file (Windows → WSL)
SHARED_THEME_FILE=$(wslpath "$(cmd.exe /c 'echo %USERPROFILE%' | tr -d '\r')")/.poshtheme

# Symlinked theme directory (points to Windows themes)
POSH_THEMES_LINK="$HOME/.poshthemes"

# Default theme fallback
CURRENT_THEME="paradox.omp.json"

###############################################
# Instant Theme Switcher
###############################################
set_posh_theme() {

    # Allow override via argument
    if [ -n "$1" ]; then
        CURRENT_THEME="$1"
    fi

    # Validate theme file
    if [ ! -f "$POSH_THEMES_LINK/$CURRENT_THEME" ]; then
        echo "❌ Theme not found: $POSH_THEMES_LINK/$CURRENT_THEME"
        return 1
    fi

    # Apply theme
    eval "$(oh-my-posh init bash --config "$POSH_THEMES_LINK/$CURRENT_THEME")"
    export OMP_LOADED=1

    # Atomic, Windows-safe write back to shared file
    TMP_FILE="${SHARED_THEME_FILE}.tmp"
    printf "%s\r\n" "$CURRENT_THEME" > "$TMP_FILE"
    mv -f "$TMP_FILE" "$SHARED_THEME_FILE"

    echo "✔ Theme applied: $CURRENT_THEME"
}

###############################################
# WSL Font Sync (Windows → WSL)
###############################################
sync_fonts() {
    echo "[SemperFix] Syncing fonts from Windows..."

    # Absolute path — avoids cmd.exe dependency
    WIN_FONT_DIR="/mnt/c/Windows/Fonts"
    WSL_FONT_DIR="$HOME/.local/share/fonts"

    mkdir -p "$WSL_FONT_DIR"

    cp "$WIN_FONT_DIR"/JetBrainsMono* "$WSL_FONT_DIR" 2>/dev/null

    fc-cache -f "$WSL_FONT_DIR"

    echo "[SemperFix] WSL font sync complete."
}

###############################################
# Loader Initialization
###############################################

# Load current theme from shared file if present
if [ -f "$SHARED_THEME_FILE" ]; then
    CURRENT_THEME=$(cat "$SHARED_THEME_FILE")
fi

# Apply theme on shell startup
set_posh_theme "$CURRENT_THEME"
