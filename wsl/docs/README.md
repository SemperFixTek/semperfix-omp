# SemperFix OMP WSL Integration (v2.1.0)

This directory contains the WSL-side loader and diagnostics:

- `loader/poshloader.sh` — defines `set_posh_theme`
- `bashrc/semperfix-omp-bashrc-block.sh` — block to include in `~/.bashrc`
- `diagnostics/` — scripts to debug shell, themes, and symlink behavior

## Install

1. Copy `loader/poshloader.sh` to `~/.poshloader`
2. Append `bashrc/semperfix-omp-bashrc-block.sh` to `~/.bashrc`
3. Ensure Windows writes `%USERPROFILE%\.poshtheme`
