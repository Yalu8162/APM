# Advanced Package Manager (APM) 🚀

A universal package manager wrapper with automatic system detection and multi-language support.

## 🌟 Features

- **Multiple package manager support**  
  Works with apt, pacman, yay, dnf, zypper, pkg, flatpak, snap
- **Multi-language interface**  
  Auto-detects system language (English, Russian, Spanish, Chinese)
- **Simple commands**  
  Easy syntax for install, remove, and search operations
- **Non-interactive mode**  
  `-n` flag for automatic installations
- **Advanced search**  
  Search across all available package managers
- **Version checking**  
  Displays package versions before installation

## 📦 Supported Package Managers

| Manager | Operations            | Systems                     |
|---------|-----------------------|----------------------------|
| APT     | Install, Remove, Search | Debian/Ubuntu              |
| Pacman  | Install, Remove, Search | Arch Linux                 |
| Yay     | Install, Remove, Search | Arch Linux (AUR)           |
| DNF     | Install, Remove, Search | Fedora/RHEL                |
| Zypper  | Install, Remove, Search | openSUSE                   |
| PKG     | Install, Remove, Search | FreeBSD                    |
| Flatpak | Install, Remove, Search | Cross-distro packages      |
| Snap    | Install, Remove, Search | Canonical packages         |

## ⚡ Quick Start

### Installation

```
bash
# Automatic installation
curl -sSL https://raw.githubusercontent.com/Yalu8162/APM/main/install.sh | sudo bash

# Manual installation
wget https://raw.githubusercontent.com/Yalu8162/APM/main/apm
chmod +x apm
sudo mv apm /usr/local/bin/
```

Basic Commands
```
bash

# Install package
apm package_name          # with confirmation
apm -n package_name       # without confirmation

# Search for package
apm -s package_name

# Remove package
apm -r package_name

# Version information
apm --version
```

Usage Examples

```
bash

# Install Firefox
apm firefox

# Install VLC without confirmation
apm -n vlc

# Search for Python packages
apm -s python

# Remove LibreOffice
apm -r libreoffice
```


📌 Command Line Options
Option	Long Form	Description
-h	--help	Show help message
-v	--version	Show version information
-n	--no-confirm	Install without confirmation
-s	--search	Search for packages
-r	--remove	Remove packages
🌍 Language Support

APM automatically detects your system language and supports:

    English (default)

    Русский (Russian)

    Español (Spanish)

    中文 (Simplified Chinese)

🤝 Contributing

We welcome contributions!

    Fork the repository

    Create your branch (git checkout -b feature/your-feature)

    Commit your changes (git commit -am 'Add some feature')

    Push to the branch (git push origin feature/your-feature)

    Open a Pull Request

⚠️ Troubleshooting

Issue: Command not found after installation
✅ Solution: Verify /usr/local/bin is in your PATH:
bash

echo $PATH | grep /usr/local/bin

Issue: Package managers not detected
✅ Solution: APM silently ignores unavailable package managers

Issue: Permission denied errors
✅ Solution: Use sudo when needed or check file permissions
📜 License

GNU GPL 3.0 License. See LICENSE file for details.
