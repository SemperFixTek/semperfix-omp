function Select-PoshTheme {
    param()

    $themes = Get-PoshThemes

    # Detect WSL
    $isWSL = $env:WSL_DISTRO_NAME -ne $null

    # Detect if Out-GridView is available
    $hasOGV = Get-Command Out-GridView -ErrorAction SilentlyContinue

    if (-not $isWSL -and $hasOGV) {
        # Windows GUI picker
        $choice = $themes | Out-GridView -Title "Select a SemperFix OMP Theme" -PassThru

        if ($choice) {
            Set-PoshTheme -Name $choice.Name
        }
        return
    }

    # Console fallback (WSL or Windows Terminal)
    Write-Host "Available themes:" -ForegroundColor Cyan
    $i = 1
    foreach ($t in $themes) {
        Write-Host "$i. $($t.Name)"
        $i++
    }

    $selection = Read-Host "Enter theme number"
    if ($selection -match '^\d+$' -and $selection -ge 1 -and $selection -le $themes.Count) {
        $theme = $themes[$selection - 1].Name
        Set-PoshTheme -Name $theme
    }
    else {
        Write-Host "[SemperFix] Invalid selection." -ForegroundColor Red
    }
}

