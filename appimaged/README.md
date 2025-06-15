# AppImage Daemon Configuration

This module provides configuration and setup for appimaged, the AppImage integration daemon.

## Features

- appimaged installation and configuration
- Automatic AppImage integration
- Desktop file generation
- Icon integration
- Automatic updates
- System integration

## Installation

To install the appimaged configuration:

```bash
cd appimaged
./install.sh
```

The installation process includes:
1. Installing appimaged if not present
2. Setting up configuration directories
3. Backing up existing configuration
4. Creating necessary symlinks
5. Starting and enabling the daemon

## Configuration

The configuration includes:

- AppImage integration settings
- Desktop file generation
- Icon integration
- Update settings
- System integration

### Core Features

- **AppImage Integration**:
  - Automatic AppImage detection
  - Desktop file generation
  - Icon integration
  - Update management

- **System Integration**:
  - System-wide installation
  - Automatic startup
  - Update notifications
  - Desktop environment integration

## Usage

After installation, appimaged will:
- Automatically detect and integrate AppImages
- Generate desktop files for AppImages
- Integrate AppImage icons
- Handle AppImage updates
- Provide system integration

### Manual Control

```bash
# Start the daemon
systemctl --user start appimaged

# Stop the daemon
systemctl --user stop appimaged

# Check status
systemctl --user status appimaged

# Enable/disable autostart
systemctl --user enable appimaged
systemctl --user disable appimaged
```

### Testing

To verify the installation and configuration:

```bash
./test.sh
```

The test script will check:
- appimaged installation
- Configuration file presence and validity
- Daemon status
- System integration

## Requirements

- appimaged
- systemd (for service management)
- Desktop environment with .desktop file support 