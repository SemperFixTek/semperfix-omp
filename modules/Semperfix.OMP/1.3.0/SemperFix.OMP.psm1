# Load public functions
Get-ChildItem -Path "$PSScriptRoot/Public" -Filter *.ps1 |
    ForEach-Object { . $_.FullName }

# Load private helpers
Get-ChildItem -Path "$PSScriptRoot/Private" -Filter *.ps1 |
    ForEach-Object { . $_.FullName }

# Aliases
Set-Alias List-PoshThemes Get-PoshTheme
Set-Alias Choose-PoshTheme Select-PoshTheme
Set-Alias spt Set-PoshTheme
Set-Alias cpt Select-PoshTheme
Set-Alias gpt Get-PoshTheme