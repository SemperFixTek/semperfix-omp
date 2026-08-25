function Get-PoshThemes {
    param()

    # Detect WSL
    $isWSL = $null -ne $env:WSL_DISTRO_NAME

    if ($isWSL) {
        # WSL uses symlinked ~/.poshthemes
        $themeDir = "$HOME/.poshthemes"
    }
    else {
        # Windows uses LOCALAPPDATA theme directory
        $themeDir = Join-Path $env:LOCALAPPDATA "Programs\oh-my-posh\themes"
    }

    if (-not (Test-Path $themeDir)) {
        Write-Warning "[SemperFix] Theme directory not found: $themeDir"
        return
    }

    Get-ChildItem -Path $themeDir -Filter *.omp.json |
        Select-Object Name, FullName
}
