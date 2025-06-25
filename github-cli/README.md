# GitHub CLI Configuration

This module provides configuration and setup for GitHub CLI (gh), the official command-line tool for GitHub.

## Features

- GitHub CLI installation via official apt repository
- Comprehensive command aliases for productivity
- Support for GitHub Enterprise instances
- Automatic configuration backup
- ZSH completion integration
- Custom configuration templates
- Multi-host support

## Installation

To install the GitHub CLI configuration:

```bash
cd github-cli
./install.sh
```

The installation process includes:
1. Adding the official GitHub CLI apt repository
2. Installing GitHub CLI via apt package manager
3. Setting up configuration directories
4. Backing up existing configuration
5. Installing configuration files
6. Creating necessary symlinks

## Configuration

The configuration includes:

### Main Configuration (`config.yml`)
- Default settings for GitHub CLI
- Comprehensive command aliases
- Output formatting preferences
- HTTP timeout settings
- Color and hyperlink preferences

### Hosts Configuration (`hosts.yml`)
- Support for multiple GitHub instances
- GitHub Enterprise configuration
- Per-host settings and preferences
- Authentication configuration

### Command Aliases

The module provides extensive aliases for common GitHub CLI commands:

#### Repository Management
```bash
gh repos          # List repositories
gh clone <repo>   # Clone a repository
gh fork <repo>    # Fork a repository
gh create <name>  # Create a new repository
gh browse         # Open repository in browser
```

#### Issue Management
```bash
gh issues         # List issues
gh create-issue   # Create a new issue
gh close-issue    # Close an issue
gh comment        # Add comment to issue
```

#### Pull Request Management
```bash
gh prs            # List pull requests
gh create-pr      # Create a new pull request
gh checkout-pr    # Checkout a pull request
gh review-pr      # Review a pull request
gh merge-pr       # Merge a pull request
```

#### Workflow Management
```bash
gh workflows      # List workflows
gh runs           # List workflow runs
gh rerun          # Rerun a workflow
```

#### Release Management
```bash
gh releases       # List releases
gh create-release # Create a new release
gh delete-release # Delete a release
```

#### User Management
```bash
gh users          # List users
gh follow         # Follow a user
gh unfollow       # Unfollow a user
```

#### Organization Management
```bash
gh orgs           # List organizations
gh create-org     # Create an organization
gh delete-org     # Delete an organization
```

#### Team Management
```bash
gh teams          # List teams
gh create-team    # Create a team
gh delete-team    # Delete a team
```

#### Secret Management
```bash
gh secrets        # List secrets
gh set-secret     # Set a secret
gh delete-secret  # Delete a secret
```

#### Variable Management
```bash
gh variables      # List variables
gh set-variable   # Set a variable
gh delete-variable # Delete a variable
```

#### Environment Management
```bash
gh envs           # List environments
gh create-env     # Create an environment
gh delete-env     # Delete an environment
```

#### Deployment Management
```bash
gh deployments    # List deployments
gh create-deployment # Create a deployment
gh delete-deployment # Delete a deployment
```

#### Package Management
```bash
gh packages       # List packages
gh create-package # Create a package
gh delete-package # Delete a package
```

#### Project Management
```bash
gh projects       # List projects
gh create-project # Create a project
gh delete-project # Delete a project
```

#### Discussion Management
```bash
gh discussions    # List discussions
gh create-discussion # Create a discussion
gh delete-discussion # Delete a discussion
```

#### Sponsorship Management
```bash
gh sponsorships   # List sponsorships
gh create-sponsorship # Create a sponsorship
gh delete-sponsorship # Delete a sponsorship
```

#### Codespace Management
```bash
gh codespaces     # List codespaces
gh create-codespace # Create a codespace
gh delete-codespace # Delete a codespace
```

#### Extension Management
```bash
gh extensions     # List extensions
gh install-extension # Install an extension
gh remove-extension  # Remove an extension
```

#### Configuration Management
```bash
gh configs        # List configurations
gh set-config     # Set a configuration
gh get-config     # Get a configuration
gh delete-config  # Delete a configuration
```

#### Authentication Management
```bash
gh login          # Login to GitHub
gh logout         # Logout from GitHub
gh status         # Check authentication status
gh refresh        # Refresh authentication
```

#### API Management
```bash
gh api            # Make API calls
gh api-call       # Alternative alias for API calls
```

#### Utility Commands
```bash
gh version        # Show version
gh ver            # Short alias for version
gh help           # Show help
gh h              # Short alias for help
gh status         # Show status
gh st             # Short alias for status
```

## Usage

After installation, you can use GitHub CLI with the following features:

### Basic Authentication
```bash
# Login to GitHub
gh auth login

# Check authentication status
gh auth status

# Logout from GitHub
gh auth logout
```

### Repository Operations
```bash
# Clone a repository
gh repo clone owner/repo

# View repository details
gh repo view owner/repo

# Create a new repository
gh repo create my-new-repo

# Fork a repository
gh repo fork owner/repo
```

### Issue Management
```bash
# List issues
gh issue list

# Create a new issue
gh issue create --title "Bug report" --body "Description"

# View an issue
gh issue view 123

# Add a comment
gh issue comment 123 --body "This is a comment"
```

### Pull Request Management
```bash
# List pull requests
gh pr list

# Create a pull request
gh pr create --title "Feature request" --body "Description"

# Checkout a pull request
gh pr checkout 123

# Review a pull request
gh pr review 123 --approve
```

### Workflow Management
```bash
# List workflows
gh workflow list

# View workflow runs
gh run list

# Rerun a workflow
gh run rerun 123
```

### Release Management
```bash
# List releases
gh release list

# Create a release
gh release create v1.0.0 --title "Release v1.0.0" --notes "Release notes"
```

### Gist Management
```bash
# List gists
gh gist list

# Create a gist
gh gist create file.txt --public

# View a gist
gh gist view gist-id
```

### User Management
```bash
# View user profile
gh user view username

# Follow a user
gh user follow username

# Unfollow a user
gh user unfollow username
```

### Organization Management
```bash
# List organizations
gh org list

# View organization
gh org view org-name

# Create an organization
gh org create org-name
```

### Team Management
```bash
# List teams
gh team list --org org-name

# Create a team
gh team create org-name team-name

# Add member to team
gh team add-member team-name username --org org-name
```

### Secret Management
```bash
# List secrets
gh secret list

# Set a secret
gh secret set SECRET_NAME --body "secret-value"

# Delete a secret
gh secret delete SECRET_NAME
```

### Variable Management
```bash
# List variables
gh variable list

# Set a variable
gh variable set VAR_NAME --body "variable-value"

# Delete a variable
gh variable delete VAR_NAME
```

### Environment Management
```bash
# List environments
gh environment list

# Create an environment
gh environment create env-name

# Delete an environment
gh environment delete env-name
```

### Deployment Management
```bash
# List deployments
gh deployment list

# Create a deployment
gh deployment create --ref main --environment production

# Delete a deployment
gh deployment delete deployment-id
```

### Package Management
```bash
# List packages
gh package list

# Create a package
gh package create --name package-name --type container

# Delete a package
gh package delete package-name
```

### Project Management
```bash
# List projects
gh project list

# Create a project
gh project create --title "My Project"

# Delete a project
gh project delete project-id
```

### Discussion Management
```bash
# List discussions
gh discussion list

# Create a discussion
gh discussion create --title "Discussion" --body "Content"

# Delete a discussion
gh discussion delete discussion-id
```

### Sponsorship Management
```bash
# List sponsorships
gh sponsorship list

# Create a sponsorship
gh sponsorship create username --amount 10

# Delete a sponsorship
gh sponsorship delete sponsorship-id
```

### Codespace Management
```bash
# List codespaces
gh codespace list

# Create a codespace
gh codespace create --repo owner/repo

# Delete a codespace
gh codespace delete codespace-name
```

### Extension Management
```bash
# List extensions
gh extension list

# Install an extension
gh extension install owner/extension

# Remove an extension
gh extension remove extension-name
```

### Configuration Management
```bash
# List configurations
gh config list

# Set a configuration
gh config set key value

# Get a configuration
gh config get key

# Delete a configuration
gh config delete key
```

### API Calls
```bash
# Make API calls
gh api repos/owner/repo

# POST request
gh api repos/owner/repo/issues --method POST --field title="Issue title"
```

## GitHub Enterprise Support

The module supports GitHub Enterprise instances through the `hosts.yml` configuration:

```yaml
# Example GitHub Enterprise configuration
enterprise.github.com:
  user: your-username
  git_protocol: https
  http_timeout: 30
  color: auto
  hyperlink: auto
  output: text
  limit: 30
  verbose: false
```

To use GitHub Enterprise:

1. Edit the `hosts.yml` file
2. Uncomment and configure your enterprise instance
3. Use the `--host` flag with commands:
   ```bash
   gh repo list --host enterprise.github.com
   gh auth login --host enterprise.github.com
   ```

## Testing

To verify the installation and configuration:

```bash
./test.sh
```

The test script will check:
- GitHub CLI installation via apt
- Configuration file presence and validity
- Stow symlink integrity
- Basic functionality
- Apt repository configuration

## Requirements

- Ubuntu/Debian system with apt package manager
- curl (for repository setup)
- sudo privileges (for package installation)

## Dependencies

- curl: For downloading repository signing key
- apt: For package management
- stow: For configuration management (handled by main installer)

## Troubleshooting

### Common Issues

1. **Authentication Issues**
   ```bash
   # Check authentication status
   gh auth status
   
   # Re-authenticate if needed
   gh auth login
   ```

2. **Permission Issues**
   ```bash
   # Check if GitHub CLI is executable
   ls -la /usr/bin/gh
   
   # Fix permissions if needed
   sudo chmod +x /usr/bin/gh
   ```

3. **Configuration Issues**
   ```bash
   # Check configuration
   gh config list
   
   # Reset configuration
   gh config set key value
   ```

4. **Network Issues**
   ```bash
   # Check connectivity
   curl -I https://api.github.com
   
   # Use verbose mode for debugging
   gh --verbose repo list
   ```

5. **Apt Repository Issues**
   ```bash
   # Check if repository is configured
   cat /etc/apt/sources.list.d/github-cli.list
   
   # Update package list
   sudo apt update
   
   # Reinstall if needed
   sudo apt install --reinstall gh
   ```

### Getting Help

```bash
# General help
gh help

# Command-specific help
gh repo --help
gh issue --help
gh pr --help

# Version information
gh version
```

## Integration

This module integrates with other modules in the dotfiles project:

- **ZSH Configuration**: Provides completion for GitHub CLI commands
- **Git Configuration**: Works with existing Git configuration
- **Editor Configuration**: Uses configured editor for file editing

## Security Considerations

- Authentication tokens are stored securely
- HTTPS is used by default for Git operations
- Configuration files have appropriate permissions
- Backups are created before modifications
- Official GitHub signing key is used for repository verification

## Updates

To update GitHub CLI:

```bash
# Check for updates
gh version

# Update using apt
sudo apt update && sudo apt upgrade gh

# Or reinstall using the module
cd github-cli
./install.sh
```

## Contributing

To contribute to this module:

1. Follow the project's coding standards
2. Use the Catppuccin Mocha color scheme
3. Include proper error handling
4. Add comprehensive tests
5. Update documentation

## License

This module is part of the dotfiles project and follows the same license terms. 