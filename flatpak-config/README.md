# Flatpak Configuration

This module installs and configures Flatpak on Ubuntu 24 LTS, then installs Teams for Linux from Flathub.

## Features

- Automatic installation of `flatpak` through APT
- System Flathub remote configuration
- System installation of Teams for Linux with the Flatpak package ID `com.github.IsmaelMartinez.teams_for_linux`
- Docker-safe installation and test skips

## Installed Applications

### Communication Tools
- Teams for Linux

## Installation

To install Flatpak and Teams for Linux:

```bash
./install.sh
```

The installation process includes:
1. Checking and installing `flatpak` if it is missing
2. Adding the system Flathub remote if it is not already configured
3. Installing `com.github.IsmaelMartinez.teams_for_linux` from Flathub as a system Flatpak

## Manual Commands

The module automates the following commands:

```bash
sudo apt install flatpak
sudo flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install --system flathub com.github.IsmaelMartinez.teams_for_linux
```

## Usage

Launch Teams for Linux with:

```bash
flatpak run com.github.IsmaelMartinez.teams_for_linux
```

If the application is not visible in your desktop launcher immediately after installation, restart your session.

## Testing

Run the module test script:

```bash
./test.sh
```

The test verifies:
1. The `flatpak` command is available
2. The system Flathub remote is configured
3. Teams for Linux is installed as a system Flatpak

## Notes

- This module requires sudo privileges.
- Flatpak installation and tests are skipped in Docker environments.
- Desktop integration may require a session restart after the first Flatpak installation.
