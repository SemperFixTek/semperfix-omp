#!/bin/bash
# SemperFix-OMP WSL loader (diagnostic mode)

echo "=== SemperFix WSL Loader Diagnostics ==="

# 1. Show starting directory
echo "[Diag] Starting directory: $(pwd)"

# 2. Force a safe working directory if UNC
if [[ "$(pwd)" == \\* ]]; then
    echo "[Diag] UNC path detected, forcing cd to HOME"
    cd $HOME
    echo "[Diag] New directory: $(pwd)"
fi

# 3. Resolve Windows username via cmd.exe
WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')

echo "[Diag] WIN_USER resolved as: '$WIN_USER'"

if [[ -z "$WIN_USER" ]]; then
    echo "[Error] WIN_USER is empty — Windows interop failed."
    echo "[Hint] This happens when WSL starts from a UNC path or cmd.exe cannot resolve the user."
fi

# 4. Build Windows home path
WIN_HOME="/mnt/c/Users/$WIN_USER"
echo "[Diag] WIN_HOME: $WIN_HOME"

# 5. Theme sync file
SYNC_FILE="$WIN_HOME/.poshtheme"
echo "[Diag] SYNC_FILE: $SYNC_FILE"

if [[ ! -f "$SYNC_FILE" ]]; then
    echo "[Error] Sync file not found!"
else
    echo "[Diag] Sync file contents: $(cat "$SYNC_FILE")"
fi

# 6. Windows theme directory
WIN_THEME_DIR="$WIN_HOME/AppData/Local/Programs/oh-my-posh/themes"
echo "[Diag] WIN_THEME_DIR: $WIN_THEME_DIR"

if [[ ! -d "$WIN_THEME_DIR" ]]; then
    echo "[Error] Windows theme directory not found!"
fi

# 7. WSL theme directory (symlink)
WSL_THEME_DIR="$HOME/.poshthemes"
echo "[Diag] WSL_THEME_DIR: $WSL_THEME_DIR"

if [[ -L "$WSL_THEME_DIR" ]]; then
    echo "[Diag] Symlink exists → $(readlink "$WSL_THEME_DIR")"
elif [[ -d "$WSL_THEME_DIR" ]]; then
    echo "[Diag] WARNING: .poshthemes exists but is NOT a symlink"
else
    echo "[Diag] Creating symlink: $WSL_THEME_DIR → $WIN_THEME_DIR"
    ln -s "$WIN_THEME_DIR" "$WSL_THEME_DIR"
fi

# 8. Resolve theme path using SharedSync.ps1
echo "[Diag] Calling SharedSync.ps1..."
THEME_PATH=$(pwsh -NoLogo -NoProfile -Command "& '$HOME/SemperFix/SemperFix-OMP-SharedSync.ps1'; Get-SemperFixThemePath")

echo "[Diag] SharedSync returned THEME_PATH: $THEME_PATH"

# 9. Check if theme file exists
if [[ ! -f "$THEME_PATH" ]]; then
    echo "[Error] Theme file not found at: $THEME_PATH"
    echo "[Error] WSL cannot load the theme."
else
    echo "[Diag] Theme file exists."
    echo "[Diag] Initializing Oh My Posh..."
    eval "$(oh-my-posh init bash --config "$THEME_PATH")"
fi

echo "=== End Diagnostics ==="
