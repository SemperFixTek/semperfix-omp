@{
    RootModule        = 'SemperFix.OMP.psm1'
    ModuleVersion     = '1.3.0'
    GUID              = 'b1b8e3f0-2a4f-4c9f-9f3a-ff3e2d9a7c11'
    Author            = 'Bruce (SemperFix)'
    CompanyName       = 'SemperFix'
    Description       = 'SemperFix Oh My Posh theme manager with persistence and WSL sync.'
    PowerShellVersion = '5.1'

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
