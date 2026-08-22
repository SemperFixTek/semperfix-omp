# 📘 **SemperFix‑OMP — CHANGELOG**

*All notable changes to this project will be documented in this file.*   This project adheres to ​**Semantic Versioning (SemVer)**​.

# **[Unreleased]**

### Added

* Planned support for module auto‑diagnostics
* Planned support for module integrity checker
* Planned support for installer self‑test
* Planned support for theme registry validation

### Changed

* Pending refactor of theme resolution logic
* Pending improvements to WSL loader sourcing detection

### Fixed

* Pending fix for edge‑case WSL shells that bypass `.profile`

# **[1.3.0] — 2026‑08‑21**

### Added

* **Versioned module architecture** (`modules/SemperFix.OMP/1.3.0/`)
* **Instant‑apply WSL loader** (`wsl/poshloader.sh`)
* **WSL installer** (`SemperFix-OMP-WSL-Installer.sh`)
* **Windows installer** with version‑folder support
* ​**Short aliases**​:
  * `spt` → Set‑PoshTheme
  * `gpt` → Get‑PoshTheme
  * `cpt` → Select‑PoshTheme
* **Cross‑system theme sync** (Windows ↔ WSL ↔ VM)
* **Shared theme file** (`~/.poshtheme`)
* **Private helper functions** (Resolve‑ThemePath, etc.)
* **Public function exports** (Get‑PoshTheme, Set‑PoshTheme, Select‑PoshTheme)

### Changed

* Refactored module entry file to dot‑source Public + Private folders
* Updated manifest to export correct functions + aliases
* Updated repo structure to support versioned modules
* Updated installer to detect repo root automatically
* Updated WSL loader to re‑initialize OMP without restarting WSL
* Updated theme switching logic to propagate instantly across systems

### Fixed

* Fixed WSL issue where theme only applied after restart
* Fixed VM issue where module functions were not loading
* Fixed missing Resolve‑ThemePath in Private folder
* Fixed alias export failure
* Fixed incorrect module root path in installer
* Fixed WSL loader sourcing in `.bashrc`, `.bash_profile`, `.profile`

# **[1.2.0] — 2026‑08‑19**

### Added

* Initial WSL loader prototype
* Initial cross‑system theme sync concept
* Basic theme switching commands
* Shared theme file foundation

### Changed

* Refactored Set‑PoshTheme to use shared theme file
* Improved theme resolution logic
* Updated module manifest structure

### Fixed

* Fixed early path resolution issues
* Fixed inconsistent theme naming behavior

# **[1.1.0] — 2026‑08‑17**

### Added

* Initial SemperFix.OMP module structure
* Public functions: Get‑PoshTheme, Set‑PoshTheme, Select‑PoshTheme
* Basic Windows profile integration
* Initial repo layout

### Changed

* Improved module import behavior
* Updated theme selection logic

### Fixed

* Fixed missing Public folder exports
* Fixed early manifest validation errors

# **[1.0.0] — 2026‑08‑14**

### Added

* First stable release of SemperFix‑OMP
* Basic theme switching
* Basic module manifest
* Basic module entry file
* Initial Windows support

# **[0.1.0] — 2026‑08‑11**

### Added

* First prototype
* Early theme switching logic
* Early module structure
* Initial experimentation with cross‑system sync

