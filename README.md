# APM
Advanced package manager for linux and unix-like systems
## What is APM?
### Advanced Package Manager (APM)

A universal package manager wrapper that supports multiple package managers (apt, pacman, yay, dnf, zypper, pkg, flatpak, snap) with automatic detection and multi-language support.

## Features

- 🔍 **Multi-manager support**: Works with all major package managers
- 🌍 **Multi-language**: Auto-detects system language (English, Russian, Spanish, Chinese)
- ⚡ **Quick commands**: Install, remove, search packages with simple syntax
- 🤖 **Non-interactive mode**: Supports silent installations (`-n` flag)
- 🔎 **Powerful search**: Search across all available package managers
- 📦 **Version checking**: Shows package versions before installation

## Supported Package Managers

| Manager | Supported Operations | Notes |
|---------|----------------------|-------|
| APT     | Install, Remove, Search | Debian/Ubuntu based systems |
| Pacman  | Install, Remove, Search | Arch Linux systems |
| Yay     | Install, Remove, Search | AUR helper for Arch |
| DNF     | Install, Remove, Search | Fedora/RHEL systems |
| Zypper  | Install, Remove, Search | openSUSE systems |
| PKG     | Install, Remove, Search | FreeBSD systems |
| Flatpak | Install, Remove, Search | Universal packages |
| Snap    | Install, Remove, Search | Canonical's snap packages |

## Installation

```bash
curl -o install.sh https://raw.githubusercontent.com/yourusername/apm/main/install.sh
chmod +x install.sh
sudo ./install.sh```

Or manually:

    Download the apm script

    Make it executable: chmod +x apm

    Move to PATH: sudo mv apm /usr/local/bin/

## Usage
Basic commands
```bash

# Install package
apm package_name
apm -n package_name  # install without confirmation

# Search for package
apm -s package_name

# Remove package
apm -r package_name

# Show version
apm -v

# Show help
apm -h
```
Examples
```bash

# Install Firefox with confirmation
apm firefox

# Install VLC without confirmation
apm -n vlc

# Search for Python packages
apm -s python

# Remove LibreOffice
apm -r libreoffice```

## Command Line Options
Option	Long Form	Description
-h	--help	Show help message
-v	--version	Show version information
-n	--no-confirm	Install without confirmation
-s	--search	Search for packages
-r	--remove	Remove installed packages
Language Support

APM automatically detects your system language and displays messages in:

    English (default)

    Русский (Russian)

    Español (Spanish)

    中文 (Chinese)

Contributing

Contributions are welcome! Please follow these steps:

    Fork the repository

    Create your feature branch (git checkout -b feature/fooBar)

    Commit your changes (git commit -am 'Add some fooBar')

    Push to the branch (git push origin feature/fooBar)

    Create a new Pull Request

## License

GNU General Public License 3.0. See LICENSE file for details.
## Troubleshooting

Problem: "Command not found" after installation
Solution: Ensure /usr/local/bin is in your PATH:
bash

echo $PATH | grep /usr/local/bin

Problem: Missing package managers not detected
Solution: APM silently ignores unavailable package managers

Problem: Permission denied errors
Solution: Run with sudo when needed or check file permissions
