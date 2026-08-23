###############################################
# SemperFix OMP WSL Loader (robust, no-cmd.exe)
###############################################

# Ensure Windows interop paths exist (best-effort)
export PATH="$PATH:/mnt/c/Windows/System32:/mnt/c/Windows"

###############################################
# Helper: resolve Windows user profile path
###############################################
resolve_win_userprofile() {
    # If cmd.exe exists and current working directory is not a UNC path, use it
    if command -v cmd.exe >/dev/null 2>&1; then
        # Convert current WSL path to Windows path and check for UNC prefix
        winpwd=$(wslpath -w "$PWD" 2>/dev/null || echo "")
        case "$winpwd" in
            \\* ) use_cmd=false ;;
            * ) use_cmd=true ;;
        esac

        if [ "$use_cmd" = true ]; then
            # run cmd.exe safely
            wslpath "$(cmd.exe /c 'echo %USERPROFILE%' | tr -d '\r')" 2>/dev/null && return 0
        fi
    fi

    # Fallback: guess from /mnt/c/Users using $USER if present
    WIN_USERS_DIR="/mnt/c/Users"
    if [ -d "$WIN_USERS_DIR" ]; then
        if [ -n "$USER" ] && [ -d "$WIN_USERS_DIR/$USER" ]; then
            echo "$WIN_USERS_DIR/$USER"
            return 0
        fi

        # pick first non-system user folder
        for d in "$WIN_USERS_DIR"/*; do
            name=$(basename "$d")
            case "$name" in
                "All Users"|"Default"|"Default User"|"Public"|"desktop.ini") continue ;;
                *) echo "$d"; return 0 ;;
            esac
        done
    fi

    # Last resort
    echo "/mnt/c/Users/Public"
    return 0
}

###############################################
# Shared Paths (resolved at runtime)
###############################################
WIN_USERPROFILE_PATH=$(resolve_win_userprofile)
# If resolve returned a Windows path (e.g., /mnt/c/Users/You), use it directly.
# Shared theme file lives in the Windows user profile root as .poshtheme
SHARED_THEME_FILE="$WIN_USERPROFILE_PATH/.poshtheme"

# Symlinked theme directory (points to Windows themes)
POSH_THEMES_LINK="$HOME/.poshthemes"

# Default theme fallback
CURRENT_THEME="paradox.omp.json"

###############################################
# Instant Theme Switcher
###############################################
set_posh_theme() {
    if [ -n "$1" ]; then
        CURRENT_THEME="$1"
    fi

    if [ ! -f "$POSH_THEMES_LINK/$CURRENT_THEME" ]; then
        echo "❌ Theme not found: $POSH_THEMES_LINK/$CURRENT_THEME"
        return 1
    fi

    eval "$(oh-my-posh init bash --config "$POSH_THEMES_LINK/$CURRENT_THEME")"
    export OMP_LOADED=1

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

    # Copy matching JetBrainsMono files; ignore errors
    cp "$WIN_FONT_DIR"/JetBrainsMono* "$WSL_FONT_DIR" 2>/dev/null || true

    # Rebuild font cache
    fc-cache -f "$WSL_FONT_DIR" >/dev/null 2>&1 || true

    echo "[SemperFix] WSL font sync complete."
}

###############################################
# Loader Initialization
###############################################
if [ -f "$SHARED_THEME_FILE" ]; then
    CURRENT_THEME=$(cat "$SHARED_THEME_FILE")
fi

set_posh_theme "$CURRENT_THEME"
