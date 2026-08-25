function Get-PoshThemes {
    param()

    $themeDir = "$HOME/.poshthemes"
    if (-not (Test-Path $themeDir)) {
        Write-Warning "[SemperFix] Theme directory not found: $themeDir"
        return
    }

    Get-ChildItem $themeDir -Filter *.omp.json | Select-Object Name, FullName
}
