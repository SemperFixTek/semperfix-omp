function Test-PoshFont {
    [CmdletBinding()]
    param()

    Write-Host "[SemperFix] Testing JetBrainsMono Nerd Font..." -ForegroundColor Cyan

    # Detect WSL
    $isWSL = $null -ne $env:WSL_DISTRO_NAME

    # Glyph test string
    $glyphs = "     ▓ █ Nerd Font Glyph Test"

    Write-Host $glyphs -ForegroundColor Green

    # Detect fallback glyphs (□, �, ?)
    $fallbackPattern = '[□�?]'
    $hasFallback = $glyphs -match $fallbackPattern

    if ($hasFallback) {
        Write-Warning "[SemperFix] One or more glyphs did not render correctly."
    }
    else {
        Write-Host "[SemperFix] All glyphs rendered correctly." -ForegroundColor Green
    }

    # Structured output for diagnostics
    return [PSCustomObject]@{
        Platform       = if ($isWSL) { "WSL" } else { "Windows" }
        GlyphsTested   = $glyphs
        FallbackGlyphs = $hasFallback
        Status         = if ($hasFallback) { "Degraded" } else { "Healthy" }
    }
}
