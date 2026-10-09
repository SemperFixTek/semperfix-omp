# SemperFix OMP Architecture

Layers:

- Windows Module (`SemperFix.OMP/`)
- Windows Integration (`windows/`)
- WSL Integration (`wsl/`)
- Shared Theme File (`%USERPROFILE%\.poshtheme` / `/mnt/c/Users/sfx/.poshtheme`)

Flow:

1. Windows user selects theme via `Set-PoshTheme`.
2. Module writes theme name to `%USERPROFILE%\.poshtheme`.
3. WSL loader reads `/mnt/c/Users/sfx/.poshtheme`.
4. WSL applies the same theme via `set_posh_theme`.
