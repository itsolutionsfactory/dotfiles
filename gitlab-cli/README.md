# GitLab CLI (glab)

This module manages the installation and configuration of the GitLab CLI tool (`glab`) on Ubuntu 24 LTS.

## Features

- Automatic installation of GitLab CLI (glab)
- Configuration management for GitLab CLI
- Authentication setup guidance
- Integration with GitLab.com and self-hosted GitLab instances

## Installation

To install GitLab CLI and configure it:

```bash
sudo ./install.sh
```

The installation process includes:
1. Installing GitLab CLI (glab) if not present
2. Creating backup of existing configuration
3. Installing configuration files
4. Setting up proper directory structure

## Configuration

The module provides a basic configuration structure for GitLab CLI with the SteelHome GitLab instance pre-configured (`https://gitlab.steelhome.internal/`). After installation, you need to:

1. **Authenticate with GitLab:**
   ```bash
   glab auth login
   ```

2. **For self-hosted GitLab instances (pre-configured):**
   ```bash
   glab auth login --hostname gitlab.steelhome.internal
   ```

3. **Verify authentication:**
   ```bash
   glab auth status
   ```

## Usage Examples

### Basic Commands

```bash
# View issues
glab issue list

# Create merge request for issue 123
glab mr create 123

# Check out the branch for merge request 243
glab mr checkout 243

# Watch the pipeline in progress
glab pipeline ci view

# View, approve, and merge the merge request
glab mr view
glab mr approve
glab mr merge
```

### Advanced Usage

```bash
# Work with CI/CD pipelines
glab ci run
glab ci view
glab ci retry

# Manage issues
glab issue create
glab issue close
glab issue reopen

# Work with merge requests
glab mr create
glab mr list
glab mr merge
```

## Configuration Files

The module installs configuration files to `~/.config/glab/`:

- `config.yml` - Main configuration file
- Additional configuration as needed

## Environment Variables

GitLab CLI respects the following environment variables:

- `GITLAB_TOKEN` - Personal access token for authentication
- `GITLAB_HOST` - GitLab hostname (for self-hosted instances)

## Authentication Methods

1. **Web Authentication (Recommended):**
   ```bash
   glab auth login
   ```

2. **Token Authentication:**
   ```bash
   export GITLAB_TOKEN=your_token_here
   glab auth login --stdin
   ```

3. **1Password Integration:**
   ```bash
   glab auth login --stdin < token.txt
   ```

## Docker Integration

GitLab CLI can be used as a Docker credential helper:

```bash
glab auth configure-docker
```

## Troubleshooting

### Common Issues

1. **Authentication Problems:**
   - Ensure you have a valid GitLab account
   - Check your personal access token permissions
   - Verify the GitLab hostname is correct

2. **Command Failures:**
   - Check if you're in a Git repository
   - Verify the remote is configured correctly
   - Ensure you have the necessary permissions

3. **Configuration Issues:**
   - Check `~/.config/glab/config.yml` for syntax errors
   - Verify file permissions
   - Restart your terminal session

### Getting Help

- Run `glab --help` for general help
- Run `glab <command> --help` for command-specific help
- Check the [official documentation](https://docs.gitlab.com/editor_extensions/gitlab_cli/)

## Notes

- The CLI requires Git to be installed
- Authentication is required for most operations
- Some commands require specific permissions on the GitLab instance
- The CLI works with both GitLab.com and self-hosted instances

## Related Documentation

- [GitLab CLI Documentation](https://docs.gitlab.com/editor_extensions/gitlab_cli/)
- [GitLab CLI GitHub Repository](https://github.com/profclems/glab)
- [GitLab API Documentation](https://docs.gitlab.com/ee/api/)
