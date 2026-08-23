@{
    RootModule        = 'SemperFix.OMP.psm1'
    ModuleVersion     = '1.3.1'
    GUID              = 'c1b7e4e4-9f4a-4f8b-9c3e-1e3f1b3a131f'
    Author            = 'Bruce (SemperFix)'
    CompanyName       = 'SemperFix'
    Copyright         = '(c) 2026 SemperFix'
    Description       = 'SemperFix Oh My Posh integration module with repo-aware font repair, WSL loader, diagnostics, and theme management.'
    PowerShellVersion = '7.0'

    FunctionsToExport = @(
        'Set-PoshTheme',
        'Get-PoshThemes',
        'Select-PoshTheme',
        'Repair-PoshFont',
        'Test-PoshFont',
        'Sync-PoshFontWSL'
    )

    AliasesToExport = @(
        'List-PoshThemes',
        'Choose-PoshTheme',
        'spt',
        'cpt',
        'gpt'
    )
}
