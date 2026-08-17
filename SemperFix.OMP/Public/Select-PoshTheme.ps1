function Select-PoshTheme {
<#
.SYNOPSIS
    Opens a GUI selector to choose an Oh My Posh theme.

.DESCRIPTION
    Displays all available themes in an Out-GridView picker and applies the
    selected theme using Set-PoshTheme.

.EXAMPLE
    Select-PoshTheme

.NOTES
    SemperFix OMP Module v1.3.0
#>

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
