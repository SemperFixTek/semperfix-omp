#!/usr/bin/env bash
echo "WSL Symlink Diagnostics"
echo "------------------------"

ls -l "$HOME/.poshthemes" || echo "❌ ~/.poshthemes missing"

target="$(readlink "$HOME/.poshthemes" 2>/dev/null)"
echo "Symlink target: $target"
