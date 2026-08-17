function Select-PoshTheme {
<#
.SYNOPSIS
    Opens a GUI selector to choose an Oh My Posh theme.
#>

    if (-not $env:POSH_THEMES_PATH) {
        $env:POSH_THEMES_PATH = Join-Path $env:LOCALAPPDATA 'Programs\oh-my-posh\themes'
    }

    $themes = Get-ChildItem $env:POSH_THEMES_PATH -Filter *.omp.json |
              Sort-Object Name

    if (-not $themes) {
        Write-Host "❌ No themes found in $env:POSH_THEMES_PATH" -ForegroundColor Red
        return
    }

    $selection = $themes |
        Out-GridView -Title "Select an Oh My Posh Theme" -PassThru

    if ($selection) {
        Set-PoshTheme $selection.Name
    }
}
