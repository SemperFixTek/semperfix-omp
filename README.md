# SemperFix OMP — Cross-Platform Oh My Posh Suite

SemperFix OMP provides:

- A Windows PowerShell module (`SemperFix.OMP/`)
- A WSL loader and integration layer (`wsl/`)
- A shared theme sync mechanism between Windows and WSL

## Structure

- `SemperFix.OMP/` — PowerShell module
- `windows/` — Windows integration
- `wsl/` — WSL integration
- `docs/` — architecture and troubleshooting

## Quick Start

1. Install Oh My Posh on Windows and WSL.
2. Install the `SemperFix.OMP` module into `Documents\PowerShell\Modules`.
3. Wire `SemperFix-OMP-Profile-v1.3.0.ps1` into your PowerShell profile.
4. Copy `poshloader.sh` to `~/.poshloader` in WSL.
5. Append `semperfix-omp-bashrc-block.sh` to `~/.bashrc` in WSL.
6. Use `Set-PoshTheme` in Windows; WSL will attempt to mirror the theme.

## Debugging WSL

Use scripts in `wsl/diagnostics/` to inspect:

- Shell type
- Symlink target
- Theme directory contents
- Shared theme file
