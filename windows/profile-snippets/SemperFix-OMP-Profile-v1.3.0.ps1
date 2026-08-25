# SemperFix OMP Windows Profile v1.3.1

# Remove OneDrive module path (fast version)
$oneDriveModulePath = "$HOME\OneDrive\Documents\PowerShell\Modules"
$env:PSModulePath = $env:PSModulePath.Replace("$oneDriveModulePath;", "")

# Ensure PowerShell 7 sees the correct module directory
$localModulePath = "$HOME\Documents\PowerShell\Modules"
if (-not ($env:PSModulePath -split ';' | Where-Object { $_ -eq $localModulePath })) {
    $env:PSModulePath = "$localModulePath;$env:PSModulePath"
}

# Temporary fast prompt
function Set-TemporaryPrompt {
    $global:OMP_INITIALIZED = $false
    function prompt { "PS> " }
}
Set-TemporaryPrompt

# Shared theme file
$sharedFile = Join-Path $env:USERPROFILE '.poshtheme'

# Safe read
if (Test-Path $sharedFile) {
    $raw = Get-Content $sharedFile -ErrorAction SilentlyContinue | Select-Object -First 1
    $theme = $raw.Trim()
    if ([string]::IsNullOrWhiteSpace($theme)) {
        $theme = 'paradox.omp.json'
    }
} else {
    $theme = 'paradox.omp.json'
}

# Cache theme path
$script:ThemePath = "$env:LOCALAPPDATA\Programs\oh-my-posh\themes\$theme"

# Async OMP load using first-prompt callback
Add-Type -TypeDefinition @"
using System;
public class OMPInit {
    public static bool Initialized = false;
}
"@

function prompt {
    if (-not [OMPInit]::Initialized) {
        [OMPInit]::Initialized = $true
        oh-my-posh init pwsh --config $script:ThemePath | Invoke-Expression
    }
    & $function:prompt
}

# Async SemperFix module load
Register-EngineEvent -SourceIdentifier SemperFix-Init -Action {
    Import-Module SemperFix.OMP -ErrorAction SilentlyContinue
} | Out-Null
New-Event -SourceIdentifier SemperFix-Init | Out-Null
