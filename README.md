# Ubuntu 24 LTS Dotfiles

This repository contains configuration files and setup scripts for Ubuntu 24 LTS. It uses GNU Stow for managing dotfiles and provides a streamlined way to set up a development environment.

## Overview

This project aims to provide a consistent and reproducible setup for Ubuntu 24 LTS systems, focusing on development tools and system configurations. The setup is managed through GNU Stow, which creates symbolic links to the appropriate locations in the home directory.

## Manual Setup Steps

Before running the dotfiles installation, you need to complete these manual steps:

### User Creation and Administration

1. **Create a new user:**
   ```bash
   sudo adduser [username]
   ```

2. **Give the user admin rights:**
   ```bash
   sudo usermod -aG sudo [username]
   ```

3. **Switch to the new user:**
   ```bash
   su - [username]
   ```

### Framework Laptop Firmware Update

For Framework Laptop 13 (AMD Ryzen™ AI 300 Series), update the firmware using Linux/LVFS:

1. **Ensure charger is attached:**
   - Connect your Framework Laptop to the charger before starting the update process
   - Do not disconnect the charger during the update

2. **Update firmware using fwupdmgr:**
   ```bash
   # Refresh the firmware database
   fwupdmgr refresh --force
   
   # Check for available updates
   fwupdmgr get-updates
   
   # Install all available firmware updates
   fwupdmgr update
   ```

3. **Important Notes:**
   - Ensure your laptop is connected to power during firmware updates
   - Do not interrupt the update process
   - The system may restart multiple times during the update
   - Keep the laptop plugged in throughout the entire process
   - Do not close the lid during the update process

### System Preparation

After completing the manual steps above:

1. **Update the system:**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Install essential tools:**
   ```bash
   sudo apt install -y git stow curl wget
   ```

3. **Clone this repository:**
   ```bash
   git clone <repository-url>
   cd dotfiles
   ```

## Prerequisites

- Ubuntu 24 LTS
- GNU Stow
- Basic development tools
- Framework Laptop firmware updated (if applicable)

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

This project includes the following configuration modules:

- **Kubectl** - Kubernetes command-line tool configuration
- **ZSH** - Enhanced shell with plugins and themes
- **Kitty** - Modern terminal emulator configuration
- **Certificates** - SSL/TLS certificate management
- **Neofetch** - System information display
- **AppImage** - AppImage application management
- **Snap** - Snap package configuration and management
- **APT Packages** - System package management with WireGuard VPN
- **Slack** - Slack desktop application
- **GitLab CLI** - GitLab command-line interface
- **GitHub CLI** - GitHub command-line interface
- **Vim/Neovim** - Text editor configuration

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
- Installation of development tools
- Installation of system utilities
- GLPI agent configuration
- Brave browser profile setup

#### Components
- **Communication Tools**:
  - Signal
  - Zoom
  - Microsoft Teams

- **Productivity**:
  - OnlyOffice Desktop Editors
  - ImageMagick
  - XMind (Mind Mapping Tool)

- **Development Tools**:
  - Freelens (Kubernetes IDE)
  - IntelliJ IDEA Ultimate
  - DataGrip
  - Bruno (API Testing Tool)
  - Postman (API Development Platform)

- **Entertainment**:
  - Spotify

- **System Utilities**:
  - htop

- **IT Management**:
  - GLPI

#### Key Features
- **Package Management**:
  - Automatic installation of snapd
  - Bulk package installation
  - Classic confinement support for development tools
  - Update management

- **System Integration**:
  - GLPI agent configuration with server URL
  - Brave browser profile management
  - Automatic updates
  - Security updates

#### Installation
To install the Snap configuration:

```bash
cd snap-config
sudo ./install.sh
```

After installation:
1. Verify installed packages with `snap list`
2. Check GLPI agent configuration
3. Configure Brave profiles as needed
4. Set up development tools

Note: This module requires root privileges to run and is not supported in Docker environments.

### APT Packages Configuration

The APT packages configuration provides essential system packages and network tools with the following features:

#### Core Features
- WireGuard VPN installation and configuration
- Network utilities (net-tools) installation
- ITSF-specific WireGuard server configuration
- Interactive IP address assignment
- NetworkManager integration

#### Components
- **WireGuard VPN**:
  - Modern VPN protocol for secure connections
  - ITSF server configuration (vpn-user.itsf.io:5544)
  - Interactive IP address assignment (192.168.66.X/32)
  - NetworkManager integration for easy management

- **Network Tools**:
  - netstat for network connections
  - ifconfig for interface configuration
  - route for routing table management
  - arp for ARP table management

#### Key Features
- **VPN Configuration**:
  - Automatic key generation and storage
  - ITSF server pre-configuration
  - Interactive IP assignment
  - NetworkManager integration

- **Network Management**:
  - Essential network utilities
  - System administration tools
  - Network troubleshooting capabilities

#### Installation
To install the APT packages configuration:

```bash
cd apt-packages
sudo ./install.sh
```

After installation:
1. Configure your WireGuard IP address when prompted
2. Connect to VPN using NetworkManager or `nmcli connection up itsf`
3. Test network tools with `netstat -tuln`, `ifconfig`, etc.

Note: This module requires root privileges to run.

### Slack Configuration

The Slack configuration provides direct installation of the Slack desktop application with the following features:

#### Core Features
- Direct .deb package download and installation
- Automatic dependency resolution
- Desktop integration
- Version verification and testing

#### Components
- **Slack Desktop Application**:
  - Latest version (4.36.130) installation
  - Desktop file creation for application menu
  - System integration
  - Automatic updates support

#### Key Features
- **Installation Process**:
  - Direct .deb package download
  - Automatic dependency resolution
  - Desktop integration
  - Version verification

- **System Integration**:
  - Application menu integration
  - Desktop file creation
  - Proper permissions setup
  - Update management

#### Installation
To install the Slack configuration:

```bash
cd slack
sudo ./install.sh
```

After installation:
1. Launch Slack with `slack` command
2. Sign in to your workspace
3. Configure notifications and preferences

Note: This module requires root privileges to run.

### GitLab CLI Configuration

The GitLab CLI configuration provides command-line access to GitLab with the following features:

#### Core Features
- GitLab CLI (glab) installation
- SteelHome GitLab instance pre-configuration
- Authentication setup guidance
- Command-line GitLab integration

#### Components
- **GitLab CLI (glab)**:
  - Command-line GitLab access
  - Issue and merge request management
  - CI/CD pipeline management
  - Repository operations

#### Key Features
- **Pre-configured Instance**:
  - SteelHome GitLab instance (https://gitlab.steelhome.internal/)
  - Ready-to-use configuration
  - Authentication guidance

- **GitLab Operations**:
  - Issue management
  - Merge request operations
  - Pipeline monitoring
  - Repository management

#### Installation
To install the GitLab CLI configuration:

```bash
cd gitlab-cli
./install.sh
```

After installation:
1. Run `glab auth login` to authenticate
2. Test with `glab issue list` or `glab mr list`
3. Configure additional settings as needed

### GitHub CLI Configuration

The GitHub CLI configuration provides command-line access to GitHub with the following features:

#### Core Features
- GitHub CLI (gh) installation and configuration
- General configuration setup
- Authentication guidance
- Command-line GitHub integration

#### Components
- **GitHub CLI (gh)**:
  - Command-line GitHub access
  - Repository management
  - Issue and pull request operations
  - GitHub Actions integration

#### Key Features
- **Configuration Management**:
  - General GitHub CLI settings
  - User-specific configuration
  - Authentication setup

- **GitHub Operations**:
  - Repository cloning and management
  - Issue and PR operations
  - GitHub Actions workflow management
  - Code review tools

#### Installation
To install the GitHub CLI configuration:

```bash
cd github-cli
./install.sh
```

After installation:
1. Run `gh auth login` to authenticate
2. Create your own `hosts.yml` file for personal settings
3. Test with `gh repo list` or `gh issue list`

### Vim/Neovim Configuration

The Vim/Neovim configuration provides a modern and feature-rich editing experience with the following features:

#### Core Features
- Modern Neovim configuration using Lua
- Plugin management with lazy.nvim
- Beautiful Catppuccin theme integration
- Smart code completion
- Snippet support
- File navigation and fuzzy finding
- Git integration
- Status line and tab visualization

#### Components
- **Plugin Management**:
  - lazy.nvim for efficient plugin loading
  - Automatic plugin installation
  - Dependency management
  - Version control

- **Completion System**:
  - Smart code completion
  - Snippet support with luasnip
  - Buffer and path completion
  - Beautiful completion menu with icons

- **File Management**:
  - nvim-tree for file browsing
  - Telescope for fuzzy finding
  - Buffer management with bufferline
  - Tab visualization

#### Key Features
- **Editor Experience**:
  - Modern Lua configuration
  - Beautiful Catppuccin theme
  - Smart indentation
  - Line numbers and relative numbers
  - Mouse support
  - Clipboard integration

- **Navigation**:
  - File explorer with nvim-tree
  - Fuzzy finding with Telescope
  - Buffer navigation
  - Tab management
  - Smart completion

- **Visual Enhancements**:
  - Status line with lualine
  - Tab visualization with bufferline
  - Syntax highlighting with treesitter
  - Git integration with gitsigns

#### Installation
To install the Vim/Neovim configuration:

```bash
cd vim
./install.sh
```

After installation:
1. Open Neovim with `nvim`
2. Wait for plugins to install
3. Restart Neovim to apply all changes

Note: This configuration requires Neovim 0.9.5 or higher.

## Contributing

Feel free to submit issues and enhancement requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 