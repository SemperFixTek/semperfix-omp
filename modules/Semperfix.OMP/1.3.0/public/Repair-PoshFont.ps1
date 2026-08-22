function Repair-PoshFont {
    [CmdletBinding()]
    param()

    Write-Host "[SemperFix] Repairing JetBrainsMono Nerd Font..." -ForegroundColor Yellow

    $fontTarget = "$env:WINDIR\Fonts"
    $repoRoot = Split-Path $PSScriptRoot -Parent
    $fontSource = Join-Path $repoRoot "windows\fonts"

    if (-not (Test-Path $fontSource)) {
        Write-Error "Font source folder not found: $fontSource"
        return
    }

    # Remove old fonts
    Get-ChildItem $fontTarget | Where-Object { $_.Name -like "JetBrainsMono*" } | ForEach-Object {
        Write-Host "Removing: $($_.Name)"
        Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
    }

    # Reinstall
    $Shell = New-Object -ComObject Shell.Application
    $FontsFolder = $Shell.NameSpace($fontTarget)

    Get-ChildItem -Path $fontSource -Filter *.ttf | ForEach-Object {
        Write-Host "Installing: $($_.Name)"
        Copy-Item $_.FullName $fontTarget -Force
        $FontsFolder.CopyHere($_.FullName, 0x10)
    }

    Write-Host "Font repair complete." -ForegroundColor Green
}
