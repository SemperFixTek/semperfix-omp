function Resolve-WindowsUserProfile {
    if ($env:USERPROFILE) { return $env:USERPROFILE }
    return "/mnt/c/Users/Public"
}
