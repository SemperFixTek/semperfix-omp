function Get-PoshThemes {
<#
.SYNOPSIS
    Lists all available Oh My Posh themes.

.DESCRIPTION
    Retrieves all *.omp.json theme files from the configured theme directory
    and highlights the currently active theme.
#>

    if (-not $env:POSH_THEMES_PATH) {
        $env:POSH_THEMES_PATH = Join-Path $env:LOCALAPPDATA 'Programs\oh-my-posh\themes'
    }

    Write-Host "📂 Available Oh My Posh Themes:" -ForegroundColor Cyan

    Get-ChildItem $env:POSH_THEMES_PATH -Filter *.omp.json |
        Sort-Object Name |
        ForEach-Object {
            if ($_.Name -eq $env:POSH_THEMES_VERSION) {
                Write-Host " → $($_.Name) (active)" -ForegroundColor Green
            } else {
                Write-Host "   $($_.Name)"
            }
        }
}
