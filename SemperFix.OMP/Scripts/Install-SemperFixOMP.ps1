Write-Host ([char]0x1F4C2 + " Installing SemperFix OMP Module...") -ForegroundColor Cyan

$modulePath = Join-Path $env:USERPROFILE 'Documents\PowerShell\Modules\SemperFix.OMP'
$sourcePath = Split-Path -Parent $PSScriptRoot

Copy-Item -Path $sourcePath -Destination $modulePath -Recurse -Force

Write-Host ([char]0x2714 + " Installed SemperFix OMP to $modulePath") -ForegroundColor Green
