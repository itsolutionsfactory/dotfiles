# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **`fix-vpn` command** (`infra-tools-kit/fix-vpn.sh`): makes the `itsf` WireGuard connection always
  on for a laptop that needs the VPN while at the office, where the dispatcher skips it on
  `ITSF-Wifi` but some MT services only accept the VPN exit IP. Removes the dispatcher, adds
  `PersistentKeepalive = 25` if missing, re-enables autoconnect; backups under
  `~/.vpn-fix-backup/`. Whether the dispatcher should skip the VPN on the office WiFi at all
  is still to be decided.
- **certs README** : says what `root-ca.crt` is (the Monaco Telecom Group Root CA, valid until
  2041), which services chain up to it, and that the root alone is enough.
- **infra-tools-kit README** : the module was the only one in `--all` without documentation;
  the three commands (`diag-network-report`, `diag-log-report`, `update-dotfiles`), what they
  produce and where, and the `main` / `develop` restriction of `update-dotfiles`.
- **Defguard module** (`defguard/`, manual, Ubuntu only): installs the Defguard desktop client
  2.1.0 from the pinned `ubuntu-22-04-lts` GitHub release package, checked against its sha256,
  makes sure the user is in the `defguard` group and `defguard-service` is running, and warns
  when `resolvconf` is missing. It then reads the `Groups:` line of `/proc/<pid>/status` for the
  user's systemd manager and the running client: the client can only reach the service once the
  session carries the group, and a logout and login is not always enough on Ubuntu, so the
  script tells whether a reboot is required and asks before rebooting. Skipped on MacOS and in Docker.

### Changed
- **Ubuntu 26.04 compatibility report and verification script** moved out of the repository root:
  `tmp-UBUNTU-26.04-COMPATIBILITY.md` is now `docs/ubuntu-26.04-compatibility.md` and
  `tmp-verify-install.sh` is now `scripts/verify-install.sh` (run it from the repository root:
  `./scripts/verify-install.sh`). The raw output of the 2026-05-29 run, `tmp-script-result.txt`,
  is deleted: its findings are summarised in section 6 of the report.
### Changed
- **README** : removed references to `test-docker.sh`, the Docker `--module` flag and an MIT
  `LICENSE` file that do not exist; Docker testing documented as `docker-compose up --build`;
  `infra-tools-kit` added to the Ubuntu `--all` order; the three manual modules (`appimaged`,
  `powershell`, `linux-config`) listed; the kubectl section says the shipped kubeconfig only
  covers the two K8sv3 clusters.

### Fixed
- **WireGuard dispatcher** : the `down` branch of `20-itsf-vpn` now only reacts to the WiFi
  interface (`wl*`), like the `up` branch already did. Any other interface going down (a
  Docker bridge, a `veth`, a USB adapter) used to stop the `itsf` connection.
- **WireGuard client config** : `PersistentKeepalive = 25` added to the `[Peer]` block of
  `/etc/wireguard/itsf.conf`, so the tunnel survives NAT mappings expiring while idle.
  Re-run `apt-packages/wireguard-setup.sh` on an existing laptop to get both fixes: with a
  private key already present it only refreshes the dispatcher and the NetworkManager
  connection.

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