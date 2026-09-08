# Cross-Platform Dotfiles

This repository contains configuration files and setup scripts for Ubuntu 24 LTS and MacOS. It uses GNU Stow for managing dotfiles and provides a streamlined way to set up a development environment.

## Overview

This project aims to provide a consistent and reproducible setup for Ubuntu 24 LTS and MacOS systems, focusing on development tools and system configurations. The setup is managed through GNU Stow, which creates symbolic links to the appropriate locations in the home directory.

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

### Ubuntu System Preparation

After completing the manual steps above on Ubuntu:

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

### MacOS System Preparation

On MacOS, the installer uses Homebrew and a `Brewfile` for package management:

1. **Install Xcode command line tools:**
   ```bash
   xcode-select --install
   ```

2. **Clone this repository:**
   ```bash
   git clone <repository-url>
   cd dotfiles
   ```

3. **Run the installer:**
   ```bash
   ./install.sh --all
   ```

If Homebrew is missing, the MacOS installer will bootstrap it from the official installer before running `brew bundle`.

## Prerequisites

- Ubuntu 24 LTS or MacOS
- GNU Stow
- Basic development tools
- Homebrew on MacOS
- Framework Laptop firmware updated (if applicable)

## Project Structure

Each directory in this repository represents a specific tool or configuration set. The structure is organized as follows:

```
.
├── README.md           # This file
├── CHANGELOG.md        # Project evolution and changes
├── install.sh          # OS dispatcher for Ubuntu and MacOS
├── install_ubuntu.sh   # Ubuntu installation script
├── install_macos.sh    # MacOS installation script
├── Brewfile            # Homebrew bundle for MacOS packages
├── test-all.sh         # Test script for all configurations
├── test-macos.sh       # Lightweight MacOS validation script
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

The root `install.sh` detects the operating system and dispatches to:
- `install_ubuntu.sh` on Linux/Ubuntu
- `install_macos.sh` on MacOS

### Interactive Installation

To install configurations interactively:

```bash
./install.sh
```

The installation process includes:
1. Checking and installing required dependencies
2. Ensuring the repository backup directory and `$HOME/.config` exist
3. Installing selected configurations with module-level backups where the module supports them

The root installers do not move or overwrite an existing `$HOME/.config` directory. Existing module configuration is handled by each module installer before it calls Stow; modules may back up, remove a repository-managed symlink, or fail with a clear conflict that requires manual review.

On MacOS, package installation is handled by Homebrew through `Brewfile`. Linux-only modules are skipped by the MacOS installer.

### Update System Packages

To update all apt, snap, and flatpak packages:

```bash
./install.sh --update
```

This will:
- Update all APT package lists
- Upgrade all installed APT packages
- Perform a full system upgrade
- Clean up unused packages
- Refresh all snap packages
- Update all system Flatpak packages

### Automatic Installation

To install all configurations automatically in a specific order:

```bash
./install.sh --all
```

On Ubuntu, this will install all modules in the following predefined order:
1. **apt-packages** - System packages and WireGuard VPN
2. **certs** - SSL/TLS certificates
3. **zsh** - Enhanced shell configuration
4. **hyfetch** - System information display
5. **snap-config** - Snap package management
6. **flatpak-config** - Flatpak package management and Teams for Linux
7. **vim** - Neovim text editor
8. **kitty** - Terminal emulator (latest upstream release, installed to `~/.local/kitty.app`)
9. **kubectl** - Kubernetes CLI tools
10. **github-cli** - GitHub command-line interface
11. **slack** - Slack desktop application
12. **docker** - Docker configuration
13. **nvm** - Node Version Manager
14. **gitlab-cli** - GitLab command-line interface
15. **infra-tools-kit** - Infrastructure tooling kit
16. **claude-code** - Claude Code CLI (Anthropic agentic coding tool)

On MacOS, this will install Homebrew packages from `Brewfile` and then install these shared modules:
1. **zsh** - Enhanced shell configuration
2. **certs** - Root CA certificate installation
3. **hyfetch** - System information display
4. **vim** - Neovim text editor
5. **kitty** - Terminal emulator (latest Homebrew cask release)
6. **kubectl** - Kubernetes CLI tools
7. **github-cli** - GitHub command-line interface
8. **gitlab-cli** - GitLab command-line interface
9. **nvm** - Node Version Manager
10. **claude-code** - Claude Code CLI (Anthropic agentic coding tool)

The MacOS installer intentionally skips Linux-specific modules: `apt-packages`, `snap-config`, `flatpak-config`, `appimaged`, `docker`, `slack`, and `powershell`.

For MacOS, `Brewfile` installs command-line tools such as WireGuard tools (`wg` and `wg-quick`) and app casks such as Docker Desktop, Slack, Microsoft Teams, Kitty, and PowerShell. Those casks only install the applications; they do not run the Linux module configuration scripts. Add a dedicated MacOS module later if an app needs Mac-specific configuration beyond installation.

On Ubuntu, the `certs` module installs the root CA through `update-ca-certificates`. On MacOS, it imports the same root CA into the System keychain and will prompt for sudo.

### Individual Module Installation

To install specific tool configurations:

```bash
stow [tool_name]
```

Note: Each module's installation script will:
1. Check for existing configuration
2. Create a backup if implemented by that module
3. Install any missing dependencies
4. Apply the configuration using stow

## Testing

### Local Testing
To test all configurations locally:

```bash
./test-all.sh
```

To run the lightweight MacOS validation checks:

```bash
./test-macos.sh
```

This validates MacOS installer syntax, the `Brewfile`, and the expected shared module layout. When run on MacOS with Homebrew available, it also asks `brew bundle` to validate the bundle file.

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
- **Claude Code** - Anthropic agentic coding CLI (latest release)
- **Certificates** - SSL/TLS certificate management
- **HyFetch** - System information display
- **Snap** - Snap package configuration and management
- **Flatpak** - Flatpak package management and Teams for Linux
- **APT Packages** - System package management with WireGuard VPN
- **Slack** - Slack desktop application
- **Docker** - Docker Engine and Docker Compose installation
- **NVM** - Node Version Manager for Node.js
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

The module always installs the **latest upstream Kitty release**, not the distro package:

- **Ubuntu/Linux** - the official binary installer from `sw.kovidgoyal.net` unpacks Kitty
  into `~/.local/kitty.app`, then `kitty` and `kitten` are symlinked into `~/.local/bin`,
  the `kitty.desktop` / `kitty-open.desktop` entries are copied into
  `~/.local/share/applications` (with absolute `Exec`/`Icon` paths), and
  `~/.config/xdg-terminals.list` is set so `xdg-terminal-exec` picks Kitty.
  The apt package is intentionally **not** used: it lags several minor releases behind
  upstream. If an apt-managed `kitty` is still present the script warns and prints the
  removal command; `~/.local/bin` takes precedence in `PATH` in the meantime.
- **MacOS** - `brew install --cask kitty`, or `brew upgrade --cask kitty` when already
  installed. Homebrew refreshes its taps automatically, so the cask is the current release.

Re-running `./install.sh` is the upgrade path: it compares the installed version against
`https://sw.kovidgoyal.net/kitty/current-version.txt` and only re-downloads when a newer
release exists. `./test.sh` reports whether the installed Kitty is behind upstream.

After installation:
1. Set Kitty as your default terminal emulator
2. Configure your system to use Hack Nerd Font
3. Restart your shell so `~/.local/bin` is on `PATH`, then restart Kitty to apply all changes

### Claude Code

Claude Code is Anthropic's agentic coding CLI. The module installs it with the official
Anthropic installer on both Ubuntu and MacOS:

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

The installer downloads the release binary for the current platform, verifies its
SHA-256 checksum against the release manifest, and runs `claude install` to place the
`claude` launcher in `~/.local/bin`. State lives in `~/.claude` and is intentionally
**not** stowed, so credentials and project history stay out of this repository.

Because the same installer covers MacOS, the `Brewfile` needs no Claude Code entry.

#### Installation
```bash
cd claude-code
./install.sh
```

Re-running the script installs the latest release over the existing one and reports the
version change, so it doubles as the update path (`claude update` works too).

> **Never run this module with `sudo`.** Claude Code installs into `$HOME`; under `sudo`
> it would land in root's home and `claude` would be missing from your own shell. Both
> this script and the upstream installer refuse to run that way.

After installation:
1. Restart your shell so `~/.local/bin` is on `PATH`
2. Run `claude` once to sign in
3. Run `claude doctor` to check installation health

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

### HyFetch Configuration

The HyFetch configuration replaces the discontinued Neofetch package with the maintained HyFetch project and provides a beautiful system information display with the following features:

#### Core Features
- HyFetch installation and configuration
- Neowofetch backend configuration for Neofetch-compatible layouts
- Acenoster theme integration with custom icons
- Hack Nerd Font support for enhanced visualization
- System information display with ASCII art logo
- Custom system specs display with improved layout

#### Components
- **HyFetch**: Maintained system information display tool
- **Neowofetch**: Maintained Neofetch-compatible backend
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
To install the HyFetch configuration:

```bash
cd hyfetch
./install.sh
```

After installation:
1. Verify the installation with `./test.sh`
2. Open a new terminal to see the system information display
3. Make sure your terminal is using Hack Nerd Font for proper icon display

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

### Flatpak Configuration

The Flatpak configuration installs Flatpak, configures Flathub, and installs Teams for Linux.

#### Core Features
- Automatic Flatpak installation through APT
- System Flathub remote configuration
- Teams for Linux system installation from Flathub

#### Components
- **Communication Tools**:
  - Teams for Linux (`com.github.IsmaelMartinez.teams_for_linux`)

#### Installation
To install the Flatpak configuration:

```bash
cd flatpak-config
./install.sh
```

After installation:
1. Verify Flatpak with `flatpak --version`
2. Verify Flathub with `flatpak remotes --system`
3. Launch Teams with `flatpak run com.github.IsmaelMartinez.teams_for_linux`

Note: This module requires sudo privileges and skips installation in Docker environments.

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

### Docker Configuration

The Docker configuration provides complete Docker Engine installation and setup with the following features:

#### Core Features
- Docker Engine installation from official Docker repository
- Docker CLI, containerd, and Docker Compose installation
- Automatic repository setup with GPG key verification
- Docker daemon management and auto-start configuration
- Comprehensive installation verification

#### Components
- **Docker Engine**: Container runtime and management
- **Docker CLI**: Command-line interface
- **containerd**: Container runtime
- **Docker Compose**: Multi-container application management
- **Docker Buildx**: Extended build capabilities

#### Key Features
- **Installation Process**:
  - Official Docker repository setup
  - GPG key verification
  - Automatic dependency resolution
  - Service configuration

- **System Integration**:
  - Docker daemon auto-start
  - User group configuration
  - Service management
  - Network configuration

#### Installation
To install Docker:

```bash
cd docker
sudo ./install.sh
```

After installation:
1. Add your user to the docker group: `sudo usermod -aG docker $USER`
2. Log out and log back in
3. Verify with `docker run hello-world`

Note: This module requires root privileges to run.

### NVM Configuration

The NVM configuration provides Node Version Manager installation and Node.js setup with the following features:

#### Core Features
- NVM installation from official repository
- Automatic shell configuration (zsh/bash)
- Node.js LTS version installation
- Automatic default version setup
- JFrog Artifactory npm registry configuration

#### Components
- **NVM**: Node Version Manager (v0.40.3)
- **Node.js**: Latest LTS version
- **npm**: Node Package Manager
- **.npmrc**: npm configuration for JFrog Artifactory

#### Key Features
- **Version Management**:
  - Multiple Node.js version support
  - Easy version switching
  - Default version configuration
  - LTS version installation

- **Configuration**:
  - Automatic shell integration
  - JFrog Artifactory registry setup
  - XDG_CONFIG_HOME support
  - Environment variable management

#### Installation
To install NVM and Node.js:

```bash
cd nvm
./install.sh
```

After installation:
1. Reload your shell: `source ~/.zshrc` or `source ~/.bashrc`
2. Verify with `nvm --version` and `node --version`
3. Check npm registry with `npm config get registry`

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