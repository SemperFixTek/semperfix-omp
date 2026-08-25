function Select-PoshTheme {
    param()

    $themes = Get-PoshThemes
    $choice = $themes | Out-GridView -Title "Select a SemperFix OMP Theme" -PassThru

    if ($choice) {
        Set-PoshTheme -Name $choice.Name
    }
}
