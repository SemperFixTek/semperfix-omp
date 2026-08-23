# SemperFix.OMP.psm1 — v1.3.1 loader

# Resolve module root and version folder
$ModuleRoot   = $PSScriptRoot
$ModuleName   = Split-Path $ModuleRoot -Leaf
$VersionFolder = Split-Path $ModuleRoot -Parent | Get-ChildItem -Directory | Sort-Object Name -Descending | Select-Object -First 1

# Dot‑source all Public functions
$PublicPath = Join-Path $ModuleRoot "public"
if (Test-Path $PublicPath) {
    Get-ChildItem -Path $PublicPath -Filter *.ps1 | ForEach-Object {
        . $_.FullName
    }
}

# Dot‑source all Private functions
$PrivatePath = Join-Path $ModuleRoot "private"
if (Test-Path $PrivatePath) {
    Get-ChildItem -Path $PrivatePath -Filter *.ps1 | ForEach-Object {
        . $_.FullName
    }
}

# Export all functions defined in Public/
$PublicFunctions = Get-ChildItem -Path $PublicPath -Filter *.ps1 |
    ForEach-Object { (Split-Path $_.Name -Leaf).Replace('.ps1','') }

Export-ModuleMember -Function $PublicFunctions


# Aliases
Set-Alias List-PoshThemes Get-PoshThemes
Set-Alias Choose-PoshTheme Select-PoshTheme
Set-Alias spt Set-PoshTheme
Set-Alias cpt Select-PoshTheme
Set-Alias gpt Get-PoshThemes