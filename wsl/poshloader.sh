# ~/.poshloader — SemperFix v1.3.1

# --- UNC PATH FIX ---
# If WSL is launched from \\wsl.localhost\..., force a safe working directory
case "$PWD" in
    \\*) cd ~ ;;
esac

# --- Resolve Windows user profile safely ---
resolve_win_userprofile() {
    if command -v cmd.exe >/dev/null 2>&1; then
        winpwd=$(wslpath -w "$PWD" 2>/dev/null || echo "")
        case "$winpwd" in
            \\*) use_cmd=false ;;
            *)   use_cmd=true ;;
        esac

        if [ "$use_cmd" = true ]; then
            wslpath "$(cmd.exe /c 'echo %USERPROFILE%' | tr -d '\r')" 2>/dev/null && return 0
        fi
    fi

    WIN_USERS_DIR="/mnt/c/Users"
    if [ -d "$WIN_USERS_DIR" ]; then
        if [ -n "$USER" ] && [ -d "$WIN_USERS_DIR/$USER" ]; then
            echo "$WIN_USERS_DIR/$USER"
            return 0
        fi

        for d in "$WIN_USERS_DIR"/*; do
            name=$(basename "$d")
            case "$name" in
                "All Users"|"Default"|"Default User"|"Public"|"desktop.ini") continue ;;
                *) echo "$d"; return 0 ;;
            esac
        done
    fi

    echo "/mnt/c/Users/Public"
}

WINHOME=$(resolve_win_userprofile)

# --- Theme path linking ---
POSH_THEMES_LINK="$WINHOME/AppData/Local/Programs/oh-my-posh/themes"

# If ~/.poshthemes does not exist, create symlink
if [ ! -e "$HOME/.poshthemes" ]; then
    ln -s "$POSH_THEMES_LINK" "$HOME/.poshthemes"
fi

# --- sync_fonts function ---
sync_fonts() {
    echo "[SemperFix] Syncing fonts from Windows..."
    mkdir -p "$HOME/.local/share/fonts"

    cp "$WINHOME/Documents/PowerShell/Modules/SemperFix.OMP/1.3.1/windows/fonts/"*.ttf \
       "$HOME/.local/share/fonts/" 2>/dev/null

    fc-cache -f
    echo "[SemperFix] WSL font sync complete."
}

# --- set_posh_theme ---
set_posh_theme() {
    theme="$1"
    if [ ! -f "$HOME/.poshthemes/$theme" ]; then
        echo "❌ Theme not found: $HOME/.poshthemes/$theme"
        return 1
    fi

    echo "$theme" > "$HOME/.poshtheme"
    echo "✔ Theme applied: $theme"
}
