Write-Host "Installing SemperFix OMP Module..." -ForegroundColor Cyan

$modulePath = "$env:USERPROFILE\Documents\PowerShell\Modules\SemperFix.OMP"
Copy-Item -Path "$PSScriptRoot\..\SemperFix.OMP" -Destination $modulePath -Recurse -Force

Write-Host "✔ Installed SemperFix OMP" -ForegroundColor Green
