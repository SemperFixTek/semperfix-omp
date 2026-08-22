# 📘 SemperFix‑OMP — Full Installation Guide

## Windows + WSL · Versioned Module Architecture · Instant Theme Sync

### This guide installs the full SemperFix‑OMP ecosystem:

-   Versioned PowerShell module
-   Windows installer
-   WSL installer
-   Instant‑apply WSL loader
-   Cross‑system theme synchronization
-   Aliases (spt, gpt, cpt)
-   Shared theme file integration

## 🧩 1. System Requirements Windows Windows 10/11

-   PowerShell 7+
-   Oh‑My‑Posh installed
-   WSL2 (Ubuntu recommended)
-   WSL Ubuntu 22.04+
-   oh-my-posh installed inside WSL
-   Windows theme directory mounted via /mnt/c

## 🧩 2. Repo Layout (Required) Your repo must match this structure:

semperfix-omp/ │ ├── installer/ │ ├── install.ps1 │ └── SemperFix-OMP-WSL-Installer.sh │ ├── modules/ │ └── SemperFix.OMP/ │ └── 1.3.0/ │ ├── SemperFix.OMP.psd1 │ ├── SemperFix.OMP.psm1 │ ├── Public/ │ ├── Private/ │ └── Shared/ │ └── wsl/ ├── poshloader.sh ├── bashrc.d/ ├── poshloader.d/ └── themes/ 

*This structure is mandatory because PowerShell only loads versioned modules when version folders exist.*

## 🧩 3. Install on Windows

1.  Clone the repo Code git clone: [https://github.com/semperfix/semperfix-omp](https://github.com/semperfix/semperfix-omp) - cd semperfix-omp/installer

     2. Run the Windows installer Code .\\install.ps1 -Force. The installer performs:

       ✔ Detect repo root 

       ✔ Copy versioned module to:

$HOME\\Documents\\PowerShell\\Modules\\SemperFix.OMP\\1.3.0

     ✔ Validate manifest 

     ✔ Import module 

     ✔ Install WSL loader (via repo root) 

     ✔ Confirm module functions load 

     ✔ Confirm aliases load (spt, gpt, cpt)

 If successful, you will see:

-    Code Module manifest validated: 
-    SemperFix.OMP 1.3.0 Module imported successfully. 
-    WSL loader installed to: ~/.poshloader

## 🧩 4. Install on WSL Navigate to the installer folder:

cd ~/projects/semperfix-omp/installer 

Run the WSL installer:

bash SemperFix-OMP-WSL-Installer.sh 

The installer performs:

✔ Install instant‑apply loader → ~/.poshloader 

✔ Add interactive guard to .bashrc, .bash\_profile, .profile 

✔ Add loader sourcing to all shell entrypoints 

✔ Ensure loader is executable 

✔ Ensure theme sync works instantly 

After installation, open a new WSL shell and verify:

Code set\_posh\_theme night-owl.omp.json Theme should update instantly

## 🧩 5. Verify Installation

1.    Verify module loads in Windows Code Get-Module SemperFix.OMP Expected:

 Version: 1.3.0 5.2 Verify aliases Code spt jandedobbeleer.omp.json gpt cpt All should work.

1.  Verify WSL loader Inside WSL:

Code set\_posh\_theme night-owl.omp.json Expected:

WSL prompt updates instantly

Windows prompt updates instantly

Shared .poshtheme file updates

5.4 Verify cross‑system sync Change theme in Windows:

Code spt paradox.omp.json Expected:

Windows updates

WSL updates instantly

VM updates instantly

🧩 6. Troubleshooting ❌ WSL theme does not update until restart Cause: Loader not sourced in .bashrc  
Fix: Re-run WSL installer.

❌ Aliases not found Cause: Manifest not exporting aliases Fix: Ensure manifest contains:

Code AliasesToExport = @('spt','gpt','cpt') ❌ Resolve‑ThemePath not found Cause: Private folder not dot‑sourced Fix: Ensure .psm1 contains:

Code Get-ChildItem $privatePath -Filter \*.ps1 | ForEach-Object { . $\_.FullName } ❌ Module loads wrong version Cause: Unversioned module exists Fix: Delete:

Code Modules\\SemperFix.OMP\\SemperFix.OMP.psm1 Modules\\SemperFix.OMP\\SemperFix.OMP.psd1 PowerShell must only see:

Code Modules\\SemperFix.OMP\\1.3.0  
🧩 7. Upgrade Procedure (Future Versions) To upgrade:

Copy modules/SemperFix.OMP/1.3.0 → modules/SemperFix.OMP/1.4.0

Apply changes inside 1.4.0

Update installer default version:

Code $ModuleVersion = "1.4.0" Commit + push

Windows installer will automatically deploy the new version.

🧩 8. Uninstall Procedure Windows Code Remove-Item -Recurse -Force "$HOME\\Documents\\PowerShell\\Modules\\SemperFix.OMP" WSL Code rm ~/.poshloader Remove sourcing lines from:

.bashrc

.bash\_profile

.profile

🧩 9. Quick Commands Task Command Change theme (Windows) spt night-owl.omp.json Change theme (WSL) set\_posh\_theme night-owl.omp.json Show current theme gpt Select theme cpt Reload profile . $PROFILE Reload WSL loader source ~/.poshloader

🧩 10. Deployment Complete You now have:

Versioned module

Cross‑system theme sync

Instant‑apply WSL loader

Windows + WSL integration

Aliases

Installer pipeline

Repo structure

SemperFix‑OMP is fully operational.