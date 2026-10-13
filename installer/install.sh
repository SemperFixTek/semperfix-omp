#!/usr/bin/env bash
# SemperFix-OMP WSL Installer v1.0.0
# Installs WSL loader, theme sync, and bashrc integration

set -e

echo "SemperFix-OMP WSL Installer v1.0.0"

# 1. Resolve paths
WSL_HOME="$HOME"
WIN_HOME="$(wslpath "$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')")"
SHARED_THEME_FILE="$WIN_HOME/.poshtheme"
WSL_LOADER="$WSL_HOME/.poshloader"
WSL_THEMES="$WSL_HOME/.posh-themes"
WIN_THEMES="$(wslpath "$(cmd.exe /c 'echo %LOCALAPPDATA%' 2>/dev/null | tr -d '\r')")/Programs/oh-my-posh/themes"

# 2. Validate oh-my-posh
#if ! command -v oh-my-posh >/dev/null 2>&1; then
#    echo "ERROR: oh-my-posh not found in WSL."
#    echo "Install it with: sudo apt install oh-my-posh"
#   exit 1
#fi

# 3. Validate shared theme file
if [ ! -f "$SHARED_THEME_FILE" ]; then
    echo "Creating shared theme file at $SHARED_THEME_FILE"
    echo "paradox.omp.json" > "$SHARED_THEME_FILE"
fi

# 4. Create WSL theme directory
mkdir -p "$WSL_THEMES"

# 5. Create symlink to Windows themes
if [ ! -L "$WSL_THEMES/windows" ]; then
    ln -s "$WIN_THEMES" "$WSL_THEMES/windows"
fi

# 6. Write loader file
cat > "$WSL_LOADER" << 'EOF'
#!/bin/bash
# SemperFix-OMP WSL loader (Windows-backed sync)

# ============================================================
# Diagnostics Mode Toggle
# Enable diagnostics by running:
#   export SEMPERFIX_WSL_DIAG=1
#   unset SEMPERFIX_WSL_DIAG
# to disable diagnostics
# ============================================================

# Prevent double-loading
if [ -n "$SEMPERFIX_WSL_LOADED" ]; then
    return
fi
export SEMPERFIX_WSL_LOADED=1

# Pull diagnostics flag from Windows environment
if [ -z "$SEMPERFIX_WSL_DIAG" ]; then
    WIN_DIAG=$(cmd.exe /c "echo %SEMPERFIX_WSL_DIAG%" 2>/dev/null | tr -d '\r')
    if [ "$WIN_DIAG" != "%SEMPERFIX_WSL_DIAG%" ] && [ -n "$WIN_DIAG" ]; then
        export SEMPERFIX_WSL_DIAG="$WIN_DIAG"
    fi
fi

DIAG=${SEMPERFIX_WSL_DIAG:-0}

if [ "$DIAG" -eq 1 ]; then
    echo "=== SemperFix WSL Loader Diagnostics ==="
    echo "[Diag] SEMPERFIX_WSL_DIAG: $SEMPERFIX_WSL_DIAG"
fi


# 1. Configure your Windows username once
WIN_USER="User"   # <-- set this to your actual Windows username

WIN_HOME="/mnt/c/Users/$WIN_USER"
SYNC_FILE="$WIN_HOME/.poshtheme"
WIN_THEME_DIR="$WIN_HOME/AppData/Local/Programs/oh-my-posh/themes"
WSL_THEME_DIR="$HOME/.poshthemes"

# ============================================================
# Diagnostics Block (only runs when DIAG=1)
# ============================================================

if [ "$DIAG" -eq 1 ]; then
    echo "=== SemperFix WSL Loader Diagnostics ==="
    echo "[Diag] WIN_HOME: $WIN_HOME"
    echo "[Diag] SYNC_FILE: $SYNC_FILE"
    echo "[Diag] WIN_THEME_DIR: $WIN_THEME_DIR"
    echo "[Diag] WSL_THEME_DIR: $WSL_THEME_DIR"
fi

# ============================================================
# Core Loader Logic (always runs)
# ============================================================

# Ensure Windows theme dir exists
if [ ! -d "$WIN_THEME_DIR" ]; then
    [ "$DIAG" -eq 1 ] && echo "[Error] Windows theme directory not found: $WIN_THEME_DIR"
    return
fi

# Ensure symlink points to Windows themes
if [ -L "$WSL_THEME_DIR" ]; then
    [ "$DIAG" -eq 1 ] && echo "[Diag] Existing symlink → $(readlink "$WSL_THEME_DIR")"
    rm "$WSL_THEME_DIR"
fi

if [ -d "$WSL_THEME_DIR" ]; then
    [ "$DIAG" -eq 1 ] && echo "[Diag] WARNING: .poshthemes is a directory, removing to create symlink"
    rm -rf "$WSL_THEME_DIR"
fi

[ "$DIAG" -eq 1 ] && echo "[Diag] Creating symlink: $WSL_THEME_DIR → $WIN_THEME_DIR"
ln -s "$WIN_THEME_DIR" "$WSL_THEME_DIR"

# Read theme name from Windows sync file
if [ -f "$SYNC_FILE" ]; then
    THEME_NAME=$(head -n 1 "$SYNC_FILE" | tr -d '\r\n')
    [ -z "$THEME_NAME" ] && THEME_NAME="jandedobbeleer.omp.json"
else
    [ "$DIAG" -eq 1 ] && echo "[Diag] Sync file missing, using default theme."
    THEME_NAME="jandedobbeleer.omp.json"
fi

THEME_PATH="$WSL_THEME_DIR/$THEME_NAME"

[ "$DIAG" -eq 1 ] && echo "[Diag] THEME_NAME: $THEME_NAME"
[ "$DIAG" -eq 1 ] && echo "[Diag] THEME_PATH: $THEME_PATH"

if [ ! -f "$THEME_PATH" ]; then
    [ "$DIAG" -eq 1 ] && echo "[Error] Theme not found: $THEME_PATH"
    return
fi

[ "$DIAG" -eq 1 ] && echo "[Diag] Initializing Oh My Posh (Windows-backed theme)..."
eval "$(oh-my-posh init bash --config "$THEME_PATH")"

[ "$DIAG" -eq 1 ] && echo "=== End Diagnostics ==="


# ============================================================
# SemperFix WSL Theme Commands (Functional)
# ============================================================

set_posh_theme() {
    local theme="$1"

    if [ -z "$theme" ]; then
        echo "Usage: set_posh_theme <theme-file>"
        return 1
    fi

    echo "[WSL] Setting theme to: $theme"

    # Write to Windows sync file
    echo "$theme" > "$SYNC_FILE"

    # Reload OMP
    local theme_path="$WSL_THEME_DIR/$theme"

    if [ ! -f "$theme_path" ]; then
        echo "[Error] Theme not found: $theme_path"
        return 1
    fi

    eval "$(oh-my-posh init bash --config "$theme_path")"
    echo "[WSL] Theme applied."
}

get_posh_theme() {
    if [ -f "$SYNC_FILE" ]; then
        head -n 1 "$SYNC_FILE"
    else
        echo "No theme set."
    fi
}

choose_posh_theme() {
    echo "Available themes:"
    ls "$WSL_THEME_DIR"/*.omp.json | sed 's#.*/##'

    echo
    read -p "Enter theme name: " theme
    set_posh_theme "$theme"
}

EOF

chmod +x "$WSL_LOADER"

# 7. Inject loader into ~/.bashrc
if ! grep -q "source ~/.poshloader" "$WSL_HOME/.bashrc"; then
    echo "" >> "$WSL_HOME/.bashrc"
    echo "# SemperFix-OMP loader" >> "$WSL_HOME/.bashrc"
    echo "source ~/.poshloader" >> "$WSL_HOME/.bashrc"
fi

echo ""
echo "SemperFix-OMP WSL installation complete."
echo "Open a new WSL session to verify theme sync."
