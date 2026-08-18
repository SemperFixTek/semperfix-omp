# Load public functions
Get-ChildItem -Path "$PSScriptRoot/Public" -Filter *.ps1 |
    ForEach-Object { . $_.FullName }

# Load private helpers
Get-ChildItem -Path "$PSScriptRoot/Private" -Filter *.ps1 |
    ForEach-Object { . $_.FullName }

# Aliases
Set-Alias List-PoshThemes Get-PoshThemes
Set-Alias Choose-PoshTheme Select-PoshTheme
