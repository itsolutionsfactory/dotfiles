# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [NOT RELEASED]

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