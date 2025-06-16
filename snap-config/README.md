# Snap Configuration

This module manages the installation and configuration of Snap packages on Ubuntu 24 LTS.

## Features

- Automatic installation of snapd
- Installation of essential applications
- Installation of productivity tools
- Installation of system utilities
- Automatic snap updates configuration
- System-wide snap settings management

## Categories of Installed Packages

### Communication Tools
- Slack
- Signal
- WhatsApp
- Zoom
- Microsoft Teams

### Productivity
- LibreOffice
- ImageMagick

### Entertainment
- Spotify
- Steam

### System Utilities
- GParted
- htop

## Installation

To install all snap packages:

```bash
sudo ./install.sh
```

The installation process includes:
1. Checking and installing snapd if not present
2. Installing all configured snap packages
3. Configuring snap settings for automatic updates
4. Listing all installed snaps

## Configuration

The script configures the following snap settings:
- Automatic updates enabled
- Daily update schedule
- Automatic security updates
- Update retention policy

## Customization

To customize the list of installed packages, edit the `SNAP_PACKAGES` array in `install.sh`. Each package can be specified with its name and any required flags (e.g., `--classic`).

## Notes

- Some packages require the `--classic` flag for full system access
- The installation process may take some time depending on your internet connection
- Some packages may require additional configuration after installation
- The script requires root privileges to run

## Troubleshooting

If you encounter issues during installation:
1. Ensure snapd is properly installed and running
2. Check your internet connection
3. Verify that the package names are correct
4. Check the snap store for package availability
5. Review the snap logs for detailed error messages 