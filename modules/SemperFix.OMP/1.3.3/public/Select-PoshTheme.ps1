function Select-PoshTheme {
    [CmdletBinding()]
    param()

    $themes = Get-PoshThemes

    # Detect WSL
    $isWSL = $null -ne $env:WSL_DISTRO_NAME

    # Detect if Out-GridView is available (PowerShell 7 requires GraphicalTools)
    $hasOGV = $null -ne (Get-Command -Name Out-GridView -ErrorAction SilentlyContinue)

    if (-not $isWSL -and $hasOGV) {
        # Windows GUI picker
        $choice = $themes | Out-GridView -Title "Select a SemperFix OMP Theme" -PassThru

        if ($null -ne $choice) {
            Set-PoshTheme -Name $choice.Name
        }
        return
    }

    # Console fallback (WSL or Windows Terminal)
    Write-Host "Available themes:" -ForegroundColor Cyan

    for ($i = 0; $i -lt $themes.Count; $i++) {
        Write-Host ("{0}. {1}" -f ($i + 1), $themes[$i].Name)
    }

    $selection = Read-Host "Enter theme number"

    if (
        $selection -match '^\d+$' -and
        [int]$selection -ge 1 -and
        [int]$selection -le $themes.Count
    ) {
        $theme = $themes[[int]$selection - 1].Name
        Set-PoshTheme -Name $theme
    }
    else {
        Write-Host "[SemperFix] Invalid selection." -ForegroundColor Red
    }
}
