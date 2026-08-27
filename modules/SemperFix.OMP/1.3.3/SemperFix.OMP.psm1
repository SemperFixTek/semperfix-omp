# SemperFix.OMP.psm1

$public  = Get-ChildItem -Path "$PSScriptRoot\Public"  -Filter *.ps1 -ErrorAction SilentlyContinue
$private = Get-ChildItem -Path "$PSScriptRoot\Private" -Filter *.ps1 -ErrorAction SilentlyContinue

foreach ($file in $public)  { . $file.FullName }
foreach ($file in $private) { . $file.FullName }

# Export only public functions; manifest handles aliases
Export-ModuleMember -Function $public.BaseName -Alias @('gpt','spt','cpt','rpf','spf')


