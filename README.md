📘 # SemperFix‑OMP Repository Structure

## Cross‑System Prompt Engine · Windows + WSL · Versioned Module Architecture

This repository contains the full SemperFix‑OMP ecosystem, including:

1. the versioned PowerShell module

2. the Windows installer

3. the WSL installer

4. the instant‑apply WSL loader

5. the theme sync engine

6. the module source code

7. the WSL support files

The repo is structured to support portable installation, versioned module deployment, and cross‑system theme synchronization.

📁 # Repository Layout Overview

📘 ## SemperFix‑OMP Repository Structure

### Cross‑System Prompt Engine · Windows + WSL · Versioned Module Architecture

This repository contains the full SemperFix‑OMP ecosystem, including:

1. the versioned PowerShell module

2. the Windows installer

3. the WSL installer

4. the instant‑apply WSL loader

5. the theme sync engine

6. the module source code

7.the WSL support files

' The repo is structured to support portable installation, versioned module deployment, and cross‑system theme synchronization.

📁 # Repository Layout Overview


Code
semperfix-omp/
│
├── installer/
│   ├── install.ps1                 # Windows module installer (version-aware)
│   └── SemperFix-OMP-WSL-Installer.sh
│
├── modules/
│   └── SemperFix.OMP/
│       └── 1.3.0/                  # Versioned module folder (required by PowerShell)
│           ├── SemperFix.OMP.psd1 # Manifest
│           ├── SemperFix.OMP.psm1 # Module entry
│           ├── Public/            # User-facing functions + aliases
│           ├── Private/           # Internal helpers (Resolve-ThemePath, etc.)
│           └── Shared/            # Shared assets (if any)
│
├── wsl/
│   ├── poshloader.sh               # Instant-apply WSL loader
│   ├── bashrc.d/                   # Optional shell fragments
│   ├── poshloader.d/               # Optional loader fragments
│   └── themes/                     # Optional theme assets
│
└── README.md                       # This document

🧩# Key Components

1. Versioned PowerShell Module
Located at:

Code
modules/SemperFix.OMP/1.3.0/
PowerShell requires this versioned folder structure.
If the version folder exists, PowerShell ignores unversioned files.

This folder contains:

Public functions

Private helpers

Shared assets

Manifest

Module entry file

All module updates must be placed inside a new version folder:

Code
modules/SemperFix.OMP/1.4.0/
2. Windows Installer
Located at:

'Code
installer/install.ps1'
Responsibilities:

Detect repo root

Copy versioned module to:

Code
$HOME\Documents\PowerShell\Modules\SemperFix.OMP\1.3.0\
Validate manifest

Import module

Install WSL loader (if present)

This installer is version-aware and supports future upgrades.

3. WSL Installer
Located at:

Code
installer/SemperFix-OMP-WSL-Installer.sh
Responsibilities:

Install instant‑apply WSL loader

Ensure loader is sourced in:

.bashrc

.bash_profile

.profile

Ensure interactive shells load correctly

Ensure loader is executable

Ensure cross‑system theme sync works

This installer fixes the “WSL theme only changes after restart” issue.

4. Instant‑Apply WSL Loader
Located at:

Code
wsl/poshloader.sh
Responsibilities:

Read shared theme file from Windows

Apply theme immediately

Reinitialize OMP without restarting WSL

Sync theme changes Windows ↔ WSL

Provide set_posh_theme command inside WSL

This loader is required for instant theme switching.

🔧 Installation Workflow
Windows
Code
cd installer
.\install.ps1 -Force
WSL
Code
cd installer
bash SemperFix-OMP-WSL-Installer.sh
🔄 Cross-System Theme Sync
Windows → WSL
Changing theme in Windows:

Code
spt night-owl.omp.json
Updates:

Windows prompt

Shared .poshtheme file

WSL prompt (instant)

WSL → Windows
Changing theme in WSL:

Code
set_posh_theme night-owl.omp.json
Updates:

Shared .poshtheme file

Windows prompt

WSL prompt (instant)

🧪 Developer Notes
Module Development
All module changes must occur inside:

Code
modules/SemperFix.OMP/<version>/
Never modify:

Code
modules/SemperFix.OMP/
PowerShell will ignore unversioned files.

Version Upgrades
To release a new version:

Copy 1.3.0 → 1.4.0

Apply changes inside 1.4.0

Update installer default version

Commit

📦 Packaging & Distribution
The repo is designed so that:

cloning the repo

running the installers

results in a fully functional SemperFix‑OMP environment on:

Windows

WSL

VM

Host

Dev machines

No manual configuration required.


Code
semperfix-omp/
│
├── installer/
│   ├── install.ps1                 # Windows module installer (version-aware)
│   └── SemperFix-OMP-WSL-Installer.sh
│
├── modules/
│   └── SemperFix.OMP/
│       └── 1.3.0/                  # Versioned module folder (required by PowerShell)
│           ├── SemperFix.OMP.psd1 # Manifest
│           ├── SemperFix.OMP.psm1 # Module entry
│           ├── Public/            # User-facing functions + aliases
│           ├── Private/           # Internal helpers (Resolve-ThemePath, etc.)
│           └── Shared/            # Shared assets (if any)
│
├── wsl/
│   ├── poshloader.sh               # Instant-apply WSL loader
│   ├── bashrc.d/                   # Optional shell fragments
│   ├── poshloader.d/               # Optional loader fragments
│   └── themes/                     # Optional theme assets
│
└── README.md                       # This document
🧩 Key Components
1. Versioned PowerShell Module
Located at:

Code
modules/SemperFix.OMP/1.3.0/
PowerShell requires this versioned folder structure.
If the version folder exists, PowerShell ignores unversioned files.

This folder contains:

Public functions

Private helpers

Shared assets

Manifest

Module entry file

All module updates must be placed inside a new version folder:

Code
modules/SemperFix.OMP/1.4.0/
2. Windows Installer
Located at:

Code
installer/install.ps1
Responsibilities:

Detect repo root

Copy versioned module to:

Code
$HOME\Documents\PowerShell\Modules\SemperFix.OMP\1.3.0\
Validate manifest

Import module

Install WSL loader (if present)

This installer is version-aware and supports future upgrades.

3. WSL Installer
Located at:

Code
installer/SemperFix-OMP-WSL-Installer.sh
Responsibilities:

Install instant‑apply WSL loader

Ensure loader is sourced in:

.bashrc

.bash_profile

.profile

Ensure interactive shells load correctly

Ensure loader is executable

Ensure cross‑system theme sync works

This installer fixes the “WSL theme only changes after restart” issue.

4. Instant‑Apply WSL Loader
Located at:

Code
wsl/poshloader.sh
Responsibilities:

Read shared theme file from Windows

Apply theme immediately

Reinitialize OMP without restarting WSL

Sync theme changes Windows ↔ WSL

Provide set_posh_theme command inside WSL

This loader is required for instant theme switching.

🔧 Installation Workflow
Windows
Code
cd installer
.\install.ps1 -Force
WSL
Code
cd installer
bash SemperFix-OMP-WSL-Installer.sh
🔄 Cross-System Theme Sync
Windows → WSL
Changing theme in Windows:

Code
spt night-owl.omp.json
Updates:

Windows prompt

Shared .poshtheme file

WSL prompt (instant)

WSL → Windows
Changing theme in WSL:

Code
set_posh_theme night-owl.omp.json
Updates:

Shared .poshtheme file

Windows prompt

WSL prompt (instant)

🧪 Developer Notes
Module Development
All module changes must occur inside:

Code
modules/SemperFix.OMP/<version>/
Never modify:

Code
modules/SemperFix.OMP/
PowerShell will ignore unversioned files.

Version Upgrades
To release a new version:

Copy 1.3.0 → 1.4.0

Apply changes inside 1.4.0

Update installer default version

Commit

📦 Packaging & Distribution
The repo is designed so that:

cloning the repo

running the installers

results in a fully functional SemperFix‑OMP environment on:

Windows

WSL

VM

Host

Dev machines

No manual configuration required.