function Test-PoshFont {
    [CmdletBinding()]
    param()

    $fontTarget = "$env:WINDIR\Fonts"

    Write-Host "[SemperFix] Running font diagnostics..." -ForegroundColor Yellow

    $installed = Get-ChildItem $fontTarget | Where-Object { $_.Name -like "JetBrainsMono*" }

    if ($installed) {
        Write-Host "JetBrainsMono Nerd Font detected:" -ForegroundColor Green
        $installed | ForEach-Object { Write-Host " - $($_.Name)" }
    } else {
        Write-Warning "JetBrainsMono Nerd Font NOT installed."
    }

    # Check Windows Terminal settings
    $wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    if (Test-Path $wtSettings) {
        $json = Get-Content $wtSettings -Raw | ConvertFrom-Json
        $profiles = $json.profiles.list

        Write-Host "`nWindows Terminal Profiles:" -ForegroundColor Yellow
        foreach ($p in $profiles) {
            Write-Host "Profile: $($p.name)"
            Write-Host "Font: $($p.font.face)"
        }
    }

    Write-Host "`nDiagnostics complete." -ForegroundColor Green
}
