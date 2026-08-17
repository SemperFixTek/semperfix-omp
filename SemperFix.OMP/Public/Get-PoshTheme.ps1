function Get-PoshThemes {

    if (-not $env:POSH_THEMES_PATH) {
        $env:POSH_THEMES_PATH = Join-Path $env:LOCALAPPDATA 'Programs\oh-my-posh\themes'
    }

    Write-Host ([char]0x1F4C2 + " Available Oh My Posh Themes:") -ForegroundColor Cyan

    Get-ChildItem $env:POSH_THEMES_PATH -Filter *.omp.json |
        Sort-Object Name |
        ForEach-Object {
            if ($_.Name -eq $env:POSH_THEMES_VERSION) {
                Write-Host (" " + [char]0x2192 + " $($_.Name) (active)") -ForegroundColor Green
            } else {
                Write-Host ("   $($_.Name)")
            }
        }
}
