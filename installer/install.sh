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
if ! command -v oh-my-posh >/dev/null 2>&1; then
    echo "ERROR: oh-my-posh not found in WSL."
    echo "Install it with: sudo apt install oh-my-posh"
    exit 1
fi

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
#!/usr/bin/env bash
# SemperFix-OMP WSL Loader

SHARED_THEME_FILE="$(wslpath "$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')")/.poshtheme"
WIN_THEMES="$(wslpath "$(cmd.exe /c 'echo %LOCALAPPDATA%' 2>/dev/null | tr -d '\r')")/Programs/oh-my-posh/themes"

# Safe read
if [ -f "$SHARED_THEME_FILE" ]; then
    theme="$(head -n 1 "$SHARED_THEME_FILE" | tr -d '\r' | xargs)"
else
    theme="paradox.omp.json"
fi

# Apply theme
oh-my-posh init bash --config "$WIN_THEMES/$theme" | source /dev/stdin

# Function to change theme from WSL
set_posh_theme() {
    echo "$1" > "$SHARED_THEME_FILE"
    echo "Theme switched to: $1"
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
