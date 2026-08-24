# SemperFix.OMP.psm1 — v1.3.1 loader

# Dot‑source all Public functions
$PublicPath = Join-Path $PSScriptRoot "public"
if (Test-Path $PublicPath) {
    Get-ChildItem -Path $PublicPath -Filter *.ps1 | ForEach-Object {
        . $_.FullName
    }
}

# Dot‑source all Private functions
$PrivatePath = Join-Path $PSScriptRoot "private"
if (Test-Path $PrivatePath) {
    Get-ChildItem -Path $PrivatePath -Filter *.ps1 | ForEach-Object {
        . $_.FullName
    }
}

# Export all functions defined in Public/
$PublicFunctions = Get-ChildItem -Path $PublicPath -Filter *.ps1 |
    ForEach-Object { (Split-Path $_.Name -Leaf).Replace('.ps1','') }

Export-ModuleMember -Function $PublicFunctions -Alias *
