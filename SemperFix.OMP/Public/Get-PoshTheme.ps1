function Get-PoshThemes {
<#
.SYNOPSIS
    Lists all available Oh My Posh themes.

.DESCRIPTION
    Retrieves all *.omp.json theme files from the configured theme directory
    and highlights the currently active theme.

.EXAMPLE
    Get-PoshThemes

.NOTES
    SemperFix OMP Module v1.3.0
#>

    Write-Host "📂 Available Oh My Posh Themes:" -ForegroundColor Cyan

    Get-ChildItem $env:POSH_THEMES_PATH -Filter *.omp.json |
        Sort-Object Name |
        ForEach-Object {
            if ($_.Name -eq $env:POSH_THEMES_VERSION) {
                Write-Host " → $_ (active)" -ForegroundColor Green
            } else {
                Write-Host "   $_"
            }
        }
}
