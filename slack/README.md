# Slack

This module manages the installation of Slack desktop application via direct .deb package download on Ubuntu 24 LTS.

## Features

- Direct .deb package download and installation
- Automatic dependency resolution
- Version verification and testing
- Desktop integration
- Comprehensive error handling

## Installation

To install Slack:

```bash
sudo ./install.sh
```

The installation process includes:
1. Checking for required dependencies (wget/curl, dpkg)
2. Downloading the latest Slack .deb package
3. Installing the package with dependency resolution
4. Verifying the installation
5. Cleaning up temporary files

## Slack Version

This module installs Slack Desktop version 4.36.130 for Linux x64.

## Dependencies

The installation requires:
- `wget` or `curl` for downloading the package
- `dpkg` for package installation
- `apt` for dependency resolution

## Usage

After installation, you can:

1. **Launch Slack:**
   ```bash
   slack
   ```

2. **Check version:**
   ```bash
   slack --version
   ```

3. **Launch from desktop:**
   - Find Slack in your applications menu
   - Or use the desktop file: `/usr/share/applications/slack.desktop`

## Configuration

### Workspace Setup

1. **Sign in to your workspace:**
   - Enter your workspace URL
   - Use your email and password
   - Complete two-factor authentication if enabled

2. **Configure notifications:**
   - Go to Preferences > Notifications
   - Set up desktop notifications
   - Configure sound preferences

3. **Customize appearance:**
   - Choose your theme (light/dark)
   - Set sidebar preferences
   - Configure message display options

### Advanced Configuration

1. **Keyboard shortcuts:**
   - Go to Preferences > Advanced
   - Configure custom shortcuts
   - Set up global shortcuts

2. **File sharing:**
   - Configure file upload preferences
   - Set up integration with cloud storage
   - Manage file sharing permissions

3. **Integrations:**
   - Connect with external services
   - Set up webhooks
   - Configure bot integrations

## Troubleshooting

### Common Issues

1. **Installation fails:**
   ```bash
   # Check dependencies
   sudo apt update
   sudo apt install wget curl dpkg
   
   # Retry installation
   sudo ./install.sh
   ```

2. **Slack won't start:**
   ```bash
   # Check if Slack is installed
   which slack
   
   # Check version
   slack --version
   
   # Check desktop file
   ls -la /usr/share/applications/slack.desktop
   ```

3. **Permission issues:**
   ```bash
   # Check binary permissions
   ls -la /usr/bin/slack
   
   # Fix permissions if needed
   sudo chmod +x /usr/bin/slack
   ```

4. **Desktop integration issues:**
   ```bash
   # Update desktop database
   sudo update-desktop-database
   
   # Refresh application menu
   sudo update-menus
   ```

### Getting Help

- **Slack Help Center:** [slack.com/help](https://slack.com/help)
- **Slack Community:** [slackcommunity.com](https://slackcommunity.com)
- **Command line help:** `slack --help`

## Updates

To update Slack:

1. **Check current version:**
   ```bash
   slack --version
   ```

2. **Download latest version:**
   - Visit [slack.com/downloads](https://slack.com/downloads)
   - Download the latest .deb package
   - Install with: `sudo dpkg -i slack-desktop-*.deb`

3. **Or re-run the installation script:**
   ```bash
   sudo ./install.sh
   ```

## Uninstallation

To remove Slack:

```bash
sudo apt remove slack-desktop
sudo apt autoremove
```

## Notes

- Slack requires an internet connection for full functionality
- Workspace access requires valid credentials
- Some features may require workspace administrator permissions
- The application integrates with system notifications
- File sharing capabilities depend on workspace settings

## Related Documentation

- [Slack Desktop App](https://slack.com/downloads/linux)
- [Slack Help Center](https://slack.com/help)
- [Slack API Documentation](https://api.slack.com/)
