# ────────────────────────────────────────────────
# SemperFix OMP v2.1.0 (WSL) — Unified Theme Loader
# ────────────────────────────────────────────────

# Ensure theme directory exists BEFORE anything else
if [ -L "$HOME/.poshthemes" ] || [ -d "$HOME/.poshthemes" ]; then
    rm -rf "$HOME/.poshthemes"
fi
ln -s /mnt/c/Users/sfx/AppData/Local/Programs/oh-my-posh/themes "$HOME/.poshthemes"

# Prevent double-loading (bashrc is sourced twice via ~/.profile)
if [ -n "$OMP_LOADED" ]; then
    return
fi
export OMP_LOADED=1

export PATH="$HOME/.local/bin:$PATH"

# Load the poshloader (defines set_posh_theme)
source "$HOME/.poshloader"

# Load persisted theme from shared file or default
SHARED_THEME_FILE="/mnt/c/Users/sfx/.poshtheme"

if [ -f "$SHARED_THEME_FILE" ]; then
    set_posh_theme "$(cat "$SHARED_THEME_FILE")"
else
    set_posh_theme "paradox.omp.json"
fi
