# Ubuntu 24 LTS Dotfiles

This repository contains configuration files and setup scripts for Ubuntu 24 LTS. It uses GNU Stow for managing dotfiles and provides a streamlined way to set up a development environment.

## Overview

This project aims to provide a consistent and reproducible setup for Ubuntu 24 LTS systems, focusing on development tools and system configurations. The setup is managed through GNU Stow, which creates symbolic links to the appropriate locations in the home directory.

## Prerequisites

- Ubuntu 24 LTS
- GNU Stow
- Basic development tools

## Project Structure

Each directory in this repository represents a specific tool or configuration set. The structure is organized as follows:

```
.
├── README.md           # This file
├── CHANGELOG.md        # Project evolution and changes
├── install.sh          # Main installation script
├── test-all.sh         # Test script for all configurations
├── test-docker.sh      # Script to test in Docker environment
├── Dockerfile          # Docker configuration for testing
├── docker-compose.yml  # Docker Compose configuration
├── entrypoint.sh       # Docker entrypoint script
├── backup/            # Directory for storing configuration backups
│   └── .gitignore    # Ensures backup files are not tracked by git
└── [tool_name]/        # Individual tool configurations
    └── [config_files]  # Tool-specific configuration files
```

## Installation

To install all configurations:

```bash
./install.sh
```

The installation process includes:
1. Checking and installing required dependencies
2. Managing existing `.config` directory:
   - If `.config` exists, you'll be prompted to:
     - Create a backup (recommended) - backups are stored in the `backup` directory
     - Overwrite existing configuration
     - Exit installation
   - If `.config` doesn't exist, it will be created
3. Installing selected configurations with proper backups

To install specific tool configurations:

```bash
stow [tool_name]
```

Note: Each module's installation script will:
1. Check for existing configuration
2. Create a backup if needed
3. Install any missing dependencies
4. Apply the configuration using stow

## Testing

### Local Testing
To test all configurations locally:

```bash
./test-all.sh
```

### Docker Testing
To test the configuration in a Docker environment:

```bash
./test-docker.sh
```

This will:
1. Build and start a Docker container
2. Run the installation script
3. Run all tests
4. Provide an interactive ZSH shell for manual testing

## Available Configurations

### GNOME Configuration

The GNOME configuration provides enhanced desktop experience with the following features:

#### Core Features
- Workspace management with keyboard shortcuts
- GSNAP window management
- Custom GNOME extensions
- Kitty terminal integration

#### Components
- **Workspace Management**:
  - Super + Number: Switch to workspace
  - Super + Shift + Number: Move window to workspace
  - Super + T: Open Kitty terminal
  - Super + A: Application switcher

- **GSNAP Window Management**:
  - Custom grid layouts
  - Window snapping
  - Keyboard shortcuts for window management
  - Layout presets

- **GNOME Extensions**:
  - Workspace Indicator
  - Horizontal Workspaces
  - Workspace Matrix
  - GSNAP
  - Vitals (system monitoring)
  - Switcher (application switcher)

#### Key Features
- **Workspace Navigation**:
  - Quick workspace switching
  - Window movement between workspaces
  - Custom workspace layouts
  - Workspace indicators

- **Window Management**:
  - Grid-based window snapping
  - Custom layout presets
  - Keyboard shortcuts
  - Window resizing and moving

- **System Integration**:
  - Kitty as default terminal
  - System monitoring with Vitals
  - Application switching with Switcher
  - Automatic extension management

#### Installation
To install the GNOME configuration:

```bash
cd gnome-config
./install.sh
```

After installation:
1. Log out and log back in for all extensions to take effect
2. Verify workspace shortcuts (Super + Number)
3. Test window management with GSNAP
4. Check that Kitty is set as default terminal

Note: This module is not supported in Docker environments and will be skipped during container testing.

### Kubectl Configuration

The kubectl configuration provides a powerful and user-friendly Kubernetes command-line experience with the following features:

#### Core Features
- kubectl installation and configuration
- kubelogin for OIDC authentication
- Automatic backup of existing configurations
- Support for multiple clusters and contexts

#### Components
- **kubectl**: Kubernetes command-line tool
- **kubelogin**: OIDC authentication plugin
- **Configuration Management**:
  - Multiple cluster support
  - Context switching
  - Namespace management
  - OIDC authentication setup

#### Key Features
- **Cluster Management**:
  - Easy context switching
  - Namespace management
  - Cluster information access
  - Resource management

- **Authentication**:
  - OIDC integration
  - Automatic token refresh
  - Secure credential management

- **Useful Aliases**:
  - Short commands for common operations
  - Context switching shortcuts
  - Namespace management commands

#### Installation
To install the kubectl configuration:

```bash
cd kubectl
./install.sh
```

After installation:
1. Verify the installation with `./test.sh`
2. Configure your OIDC credentials if needed
3. Test cluster access with `kubectl cluster-info`

### ZSH Configuration

The ZSH configuration provides a powerful and user-friendly shell environment with the following features:

#### Core Features
- Oh My Zsh with Catppuccin Mocha theme
- Hack Nerd Font for better icon support
- Enhanced history management
- Smart directory navigation
- Advanced tab completion
- FZF integration with preview support

#### Plugins
- **zsh-autosuggestions**: Suggests commands as you type based on history
- **zsh-syntax-highlighting**: Highlights commands as you type
- **zsh-z**: Smarter directory jumping (like `cd` but remembers your most used directories)
- **zsh-history-substring-search**: Better history search with up/down arrows
- **zsh-dirhistory**: Directory history navigation
- **fzf**: Fuzzy finder for files, history, and more with preview support

#### Key Features
- **Directory Navigation**:
  - Use `z` instead of `cd` for smarter directory jumping
  - Use `d` and `f` to navigate directory history
  - Use Ctrl+Left/Right to move word by word
  - Enhanced directory history management

- **Fuzzy Finding**:
  - `Ctrl+T`: Fuzzy find files with preview
  - `Ctrl+R`: Fuzzy find in history
  - `Alt+C`: Fuzzy find directories
  - Preview support for files and directories

- **History Search**:
  - Use up/down arrows to search through history
  - Matches are highlighted as you type
  - Enhanced history management with deduplication
  - Extended history with timestamps

- **Useful Aliases**:
  - Common system commands (`ll`, `la`, `l`, etc.)
  - Git shortcuts (`gs`, `ga`, `gc`, etc.)
  - Directory navigation (`..`, `...`)
  - FZF aliases with preview support
  - System information commands

- **Completion System**:
  - Enhanced tab completion
  - Menu selection for completions
  - Case-insensitive matching
  - Colored output for better visibility
  - Grouped completions

- **Development Tools**:
  - SDKMAN integration for Java development
  - Git integration with useful aliases
  - Editor configuration
  - Path management

#### Installation
To install the ZSH configuration:

```bash
cd zsh
./install.sh
```

After installation:
1. Set your terminal emulator to use "Hack Nerd Font"
2. Restart your terminal or run `source ~/.zshrc`

### Kitty Terminal Configuration

The Kitty terminal configuration provides a modern and feature-rich terminal experience with:

#### Features
- **Catppuccin Integration**:
  - Beautiful and consistent color scheme
  - Optimized for readability
  - Support for both light and dark modes

#### Core Features
- **Custom Key Bindings**:
  - Efficient window and tab management
  - Smart copy/paste operations
  - Quick navigation shortcuts

#### Advanced Features
- **Window Management**:
  - Multiple windows and tabs
  - Split window layouts
  - Window resizing and moving

- **Performance**:
  - GPU-accelerated rendering
  - Efficient memory usage
  - Fast startup time

- **Additional Features**:
  - Scrollback buffer with search
  - Clipboard integration
  - URL detection and handling
  - Image display support
  - Unicode and emoji support

#### Installation
To install the Kitty configuration:

```bash
cd kitty
./install.sh
```

After installation:
1. Set Kitty as your default terminal emulator
2. Configure your system to use Hack Nerd Font
3. Restart Kitty to apply all changes

### Certificate Configuration

The certificate configuration provides secure management of system and user certificates with the following features:

#### Core Features
- Root CA certificate installation
- Certificate directory setup
- Automatic certificate updates
- Certificate verification
- System trust store integration

#### Components
- **Certificate Management**:
  - Root CA certificate installation
  - Certificate directory structure
  - Certificate verification setup
  - Trust store configuration

#### Key Features
- **Certificate Installation**:
  - Automatic installation in system trust store
  - Proper permission management
  - Secure certificate storage
  - Backup of existing certificates

- **System Integration**:
  - Integration with system trust store
  - Automatic certificate updates
  - Proper file permissions
  - Secure storage location

#### Installation
To install the certificate configuration:

```bash
cd certs
./install.sh
```

After installation:
1. Verify the installation with `./test.sh`
2. Check that the certificate is properly installed in the system trust store
3. Verify that the certificate is valid and trusted

### Neofetch Configuration

The Neofetch configuration provides a beautiful system information display with the following features:

#### Core Features
- Neofetch installation and configuration
- Acenoster theme integration with custom icons
- Hack Nerd Font support for enhanced visualization
- System information display with ASCII art logo
- Custom system specs display with improved layout

#### Components
- **Neofetch**: System information display tool
- **Acenoster Theme**: Beautiful and informative display theme
- **Hack Nerd Font**: Icon support for better visualization
- **Custom Layout**: Enhanced system information organization

#### Key Features
- **System Information Display**:
  - ASCII art logo of your distribution
  - Detailed system specifications with custom icons
  - Uptime information
  - Battery status (for laptops)
  - Memory and disk usage
  - CPU and GPU information
  - Package management information
  - Desktop environment details

- **Theme Integration**:
  - Beautiful Acenoster theme
  - Proper icon support with Nerd Fonts
  - Clean and organized layout
  - Consistent color scheme
  - Custom information grouping

#### Installation
To install the Neofetch configuration:

```bash
cd neofetch
./install.sh
```

After installation:
1. Verify the installation with `./test.sh`
2. Open a new terminal to see the system information display
3. Make sure your terminal is using Hack Nerd Font for proper icon display

### AppImage Configuration

The AppImage configuration provides seamless integration of AppImages into your system with the following features:

#### Core Features
- appimaged daemon installation and configuration
- Automatic AppImage detection and integration
- Desktop file generation
- Icon integration
- Update management
- Applications directory setup

#### Components
- **appimaged**: AppImage daemon for system integration
- **Configuration Management**:
  - Applications directory setup
  - Desktop integration
  - Icon integration
  - Update checks

#### Key Features
- **AppImage Management**:
  - Automatic detection of AppImages
  - Desktop file generation
  - Icon integration
  - Update notifications

- **System Integration**:
  - Desktop environment integration
  - Icon theme integration
  - Update management
  - Systemd service setup

- **Directory Structure**:
  - Dedicated Applications directory
  - Proper file permissions
  - Automatic cleanup

#### Installation
To install the AppImage configuration:

```bash
cd appimaged
./install.sh
```

After installation:
1. Verify the installation with `./test.sh`
2. Place AppImages in your Applications directory
3. Restart your session for all changes to take effect

Note: This module is not supported in Docker environments and will be skipped during container testing.

### Snap Configuration

The Snap configuration provides a streamlined package management solution with the following features:

#### Core Features
- Automatic snapd installation and configuration
- Installation of essential applications
- Installation of productivity tools
- Installation of system utilities
- Automatic snap updates configuration

#### Components
- **Communication Tools**:
  - Slack
  - Signal
  - WhatsApp
  - Zoom
  - Microsoft Teams

- **Productivity**:
  - LibreOffice
  - ImageMagick

- **Entertainment**:
  - Spotify
  - Steam

- **System Utilities**:
  - GParted
  - htop

#### Key Features
- **Package Management**:
  - Automatic installation of snapd
  - Bulk package installation
  - Classic confinement support
  - Update management

- **System Integration**:
  - Automatic updates
  - Daily update schedule
  - Security updates
  - Update retention policy

#### Installation
To install the Snap configuration:

```bash
cd snap-config
sudo ./install.sh
```

After installation:
1. Verify installed packages with `snap list`
2. Check snap update status with `snap refresh --list`
3. Configure any additional package settings as needed

Note: This module requires root privileges to run and is not supported in Docker environments.

## Contributing

Feel free to submit issues and enhancement requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 