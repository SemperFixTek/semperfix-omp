# SemperFix OMP Loader v2.1.0 (WSL)
# Cross-platform theme sync via shared file

POSH_THEMES_PATH="$HOME/.poshthemes"
SHARED_THEME_FILE="/mnt/c/Users/sfx/.poshtheme"

set_posh_theme() {
    theme="$1"
    theme_path="$POSH_THEMES_PATH/$theme"

    if [ ! -f "$theme_path" ]; then
        echo "❌ Theme not found: $theme_path"
        return 1
    fi

    echo "$theme" > "$SHARED_THEME_FILE"

    if [ -n "$ZSH_VERSION" ]; then
        eval "$(oh-my-posh init zsh --config "$theme_path")"
    else
        eval "$(oh-my-posh init bash --config "$theme_path")"
    fi

    echo "✔ Theme switched to: $theme"
}
