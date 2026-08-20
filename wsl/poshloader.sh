###############################################
# SemperFix Loader v3.2 — Symlink-Aware Edition
###############################################

# Guard against recursive sourcing
if [ -n "$POSH_LOADER_GUARD" ]; then
    return
fi
export POSH_LOADER_GUARD=1

# Linux-native theme directory
POSH_THEMES_TARGET="$HOME/.local/share/oh-my-posh/themes"
POSH_THEMES_LINK="$HOME/.poshthemes"

# Ensure theme directory exists
if [ ! -d "$POSH_THEMES_TARGET" ]; then
    mkdir -p "$POSH_THEMES_TARGET"
fi

# Create symlink ONLY if missing
if [ ! -L "$POSH_THEMES_LINK" ]; then
    ln -s "$POSH_THEMES_TARGET" "$POSH_THEMES_LINK"
fi

# Shared theme file (Windows ↔ WSL)
SHARED_THEME_FILE="/mnt/c/Users/User/.poshtheme"

# Resolve theme name (strip CR/LF and spaces, fallback if empty)
if [ -f "$SHARED_THEME_FILE" ]; then
    RAW_THEME="$(cat "$SHARED_THEME_FILE" 2>/dev/null || echo "")"
    CURRENT_THEME="$(echo "$RAW_THEME" | tr -d '\r\n ' )"
    if [ -z "$CURRENT_THEME" ]; then
        CURRENT_THEME="paradox.omp.json"
    fi
else
    CURRENT_THEME="paradox.omp.json"
fi



###############################################
# Diagnostics (only if SEMPERFIX_DIAGNOSTICS=1)
###############################################
if [ -n "$SEMPERFIX_DIAGNOSTICS" ]; then
    echo "----- SemperFix Loader Diagnostic -----"
    echo "Loader invoked at: $(date)"
    echo "PWD: $PWD"
    echo "HOME: $HOME"
    echo "Theme argument received: '$1'"
    echo "Shared theme file: $SHARED_THEME_FILE"
    echo "Shared theme file contents: $CURRENT_THEME"
    echo "Symlink target:"
    ls -l "$POSH_THEMES_LINK"
    echo "PATH at loader runtime:"
    echo "$PATH"
    echo "Which oh-my-posh:"
    which oh-my-posh
    echo "OMP_LOADED: $OMP_LOADED"
    echo "POSH_LOADER_GUARD: $POSH_LOADER_GUARD"
    echo "----------------------------------------"
fi

###############################################
# Define set_posh_theme() — THIS WAS MISSING
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
