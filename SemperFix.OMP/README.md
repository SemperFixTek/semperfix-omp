# SemperFix.OMP PowerShell Module (v1.3.0)

A Windows PowerShell module for managing Oh My Posh themes with:

- Persistent theme selection
- Shared theme file for WSL sync (`%USERPROFILE%\.poshtheme`)
- Interactive theme picker
- POSH_THEMES_VERSION tracking

## Commands

- `Set-PoshTheme <ThemeName>`
- `Get-PoshThemes`
- `Select-PoshTheme`
- Aliases: `List-PoshThemes`, `Choose-PoshTheme`

## Requirements

- PowerShell 5.1+
- Oh My Posh installed
- Themes in `%LOCALAPPDATA%\Programs\oh-my-posh\themes`
