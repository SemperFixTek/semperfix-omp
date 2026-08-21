# SemperFix.OMP — Module Entry File

# Load public functions
$publicPath = Join-Path $PSScriptRoot 'Public'
Get-ChildItem -Path $publicPath -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

# Load private helper functions
$privatePath = Join-Path $PSScriptRoot 'Private'
Get-ChildItem -Path $privatePath -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

# Shared theme file
$Script:SharedThemeFile = Join-Path $env:USERPROFILE '.poshtheme'

function Write-ThemeFile {
    param([string]$Theme)
    Set-Content -Path $Script:SharedThemeFile -Value $Theme -Encoding ASCII
}

function Read-ThemeFile {
    if (Test-Path $Script:SharedThemeFile) {
        $raw = Get-Content $Script:SharedThemeFile -ErrorAction SilentlyContinue | Select-Object -First 1
        return $raw.Trim()
    }
    return 'paradox.omp.json'
}

Export-ModuleMember -Function * -Alias *
