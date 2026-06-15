# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0]

### Added
- **WireGuard dispatcher** : automatic VPN startup via NetworkManager dispatcher
  - VPN is skipped when connected to the corporate network (`ITSF-Wifi`)
  - VPN waits for a valid IP assignment on the WiFi interface before attempting to connect
  - VPN waits for actual connectivity to the WireGuard endpoint (`vpn-user.itsf.io`) before starting
  - All dispatcher decisions are logged to the system journal (`journalctl -t nm-dispatcher`)

### Changed
- **WireGuard** : disabled NetworkManager `autoconnect` on the `itsf` connection — startup is now fully managed by the dispatcher

## [1.2.0]

### Removed
- **GNOME Configuration Module**: Removed entire gnome-config module due to installation issues
  - GNOME extensions installation was not working properly
  - Module was not mandatory for the dotfiles setup
  - Simplified installation process by removing problematic module
  - Removed 9 files including install scripts, configurations, and documentation

## [1.0.0] - 2024-03-19

### Added
- Initial project setup
- Basic directory structure
- README.md with project documentation
- CHANGELOG.md for tracking changes
- install.sh script for automated setup
- Docker testing environment:
  - Dockerfile for building test container
  - docker-compose.yml for container orchestration
  - test-docker.sh for running tests in Docker
  - entrypoint.sh for container initialization

### Snap Configuration
- Added snap package management module
- Implemented automatic snapd installation
- Added streamlined package installation:
  - Communication tools (Slack, Signal, WhatsApp, etc.)
  - Productivity tools (LibreOffice, ImageMagick)
  - Entertainment (Spotify, Steam)
  - System utilities (GParted, htop)
- Configured automatic snap updates
- Added daily update schedule
- Implemented security update management
- Created comprehensive test suite
- Added Docker environment detection
- Implemented graceful skipping in containers
- Created detailed documentation

### GNOME Configuration
- Added GNOME workspace management with keyboard shortcuts
- Implemented GSNAP window management with custom layouts
- Added GNOME extensions:
  - Workspace Indicator
  - Horizontal Workspaces
  - Workspace Matrix
  - GSNAP
  - Vitals (system monitoring)
  - Switcher (application switcher)
- Configured keyboard shortcuts:
  - Super + Number: Switch to workspace
  - Super + Shift + Number: Move window to workspace
  - Super + T: Open Kitty terminal
  - Super + A: Application switcher
- Set up Kitty as default terminal
- Added automatic extension management
- Created comprehensive test suite
- Added Docker environment detection
- Implemented graceful skipping in containers
- Created detailed documentation

### Neofetch Configuration
- Added neofetch module for system information display
- Implemented Acenoster theme integration
- Added Hack Nerd Font support for icons
- Created custom system information script
- Added comprehensive test suite
- Implemented proper stow integration
- Created detailed documentation

### AppImage Configuration
- Added appimaged module for AppImage integration
- Implemented automatic appimaged installation
- Created Applications directory setup
- Added systemd service configuration
- Implemented desktop and icon integration
- Added update management
- Created comprehensive test suite
- Added Docker environment detection
- Implemented graceful skipping in containers
- Created detailed documentation

### Kubectl Configuration
- Added kubectl module with comprehensive setup
- Implemented automatic kubectl installation
- Added kubelogin for OIDC authentication
- Created configuration management system:
  - Multiple cluster support
  - Context switching
  - Namespace management
  - OIDC authentication setup
- Added automatic backup of existing configurations
- Implemented comprehensive test suite
- Added useful kubectl aliases and shortcuts
- Created detailed documentation

### ZSH Configuration
- Added comprehensive ZSH setup with Oh My Zsh
- Installed and configured Hack Nerd Font
- Added Catppuccin Mocha theme for Oh My Zsh
- Added essential ZSH plugins:
  - zsh-autosuggestions for command suggestions
  - zsh-syntax-highlighting for command validation
  - zsh-z for smart directory jumping
  - zsh-history-substring-search for better history navigation
  - zsh-dirhistory for directory history
  - fzf for fuzzy finding
- Added useful aliases for common commands
- Configured advanced tab completion
- Added directory navigation features
- Added fuzzy finding capabilities
- Updated documentation with ZSH features and usage

### Script Improvements
- Added checks to avoid redownloading and reinstalling existing components
- Added font installation verification
- Added stow link verification for configuration files
- Improved error handling and status messages
- Added Docker testing environment with interactive ZSH shell
- Enhanced installation process with better error handling

### Certificate Configuration
- Added certificate management module
- Implemented root CA certificate installation
- Added system trust store integration
- Created certificate verification system
- Added automatic certificate updates
- Implemented secure certificate storage
- Added comprehensive test suite
- Created detailed documentation

### Neofetch and ZSH Configuration Updates
- Updated neofetch configuration with Acenoster theme integration
- Enhanced system information display with custom icons and layout
- Improved ZSH configuration with Catppuccin Mocha theme
- Added comprehensive FZF configuration with preview support
- Enhanced directory navigation and history management
- Added useful aliases for common commands and Git operations
- Improved completion system with better visual feedback
- Added SDKMAN integration for Java development tools

### Vim/Neovim Configuration
- Added modern Neovim configuration with Lua
- Implemented plugin management with lazy.nvim
- Added Catppuccin theme integration
- Implemented smart code completion system:
  - nvim-cmp for completion
  - luasnip for snippets
  - Buffer and path completion
  - Beautiful completion menu with icons
- Added file management features:
  - nvim-tree for file browsing
  - Telescope for fuzzy finding
  - bufferline for tab visualization
- Implemented visual enhancements:
  - lualine for status line
  - treesitter for syntax highlighting
  - gitsigns for Git integration
- Created comprehensive test suite
- Added proper stow integration
- Created detailed documentation
- Ensured compatibility with Neovim 0.9.5 

## [NOT RELEASED] 

### GitHub CLI Configuration
- Added GitHub CLI module with comprehensive setup
- Implemented automatic GitHub CLI installation via official apt repository
- Added support for Ubuntu/Debian package management
- Created extensive command aliases for productivity:
  - Repository management (clone, fork, create, browse)
  - Issue management (list, create, close, comment)
  - Pull request management (list, create, checkout, review, merge)
  - Workflow management (list, runs, rerun)
  - Release management (list, create, delete)
  - User and organization management
  - Team management
  - Secret and variable management
  - Environment and deployment management
  - Package and project management
  - Discussion and sponsorship management
  - Codespace and extension management
  - Configuration and authentication management
  - API call utilities
- Added GitHub Enterprise support through hosts configuration
- Implemented automatic configuration backup
- Created comprehensive test suite with dependency verification
- Added proper stow integration for configuration management
- Created detailed documentation with usage examples
- Ensured compatibility with latest GitHub CLI versions 