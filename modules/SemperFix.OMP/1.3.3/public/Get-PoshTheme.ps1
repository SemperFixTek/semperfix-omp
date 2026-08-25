function Get-PoshTheme {
    param()

    $themeFile = "$HOME/.poshtheme"
    if (-not (Test-Path $themeFile)) {
        Write-Warning "[SemperFix] No theme selected."
        return $null
    }

    Get-Content $themeFile
}
