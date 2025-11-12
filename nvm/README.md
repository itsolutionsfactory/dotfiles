# NVM (Node Version Manager)

This module manages the installation of NVM (Node Version Manager) and Node.js on Ubuntu 24 LTS. NVM allows you to quickly install and use different versions of Node.js via the command line.

## Features

- Installation of NVM from the official repository
- Automatic shell configuration (zsh/bash)
- Installation of Node.js LTS version
- Automatic setup of default Node.js version
- Support for XDG_CONFIG_HOME environment variable
- Comprehensive installation verification
- Configuration of `.npmrc` for JFrog Artifactory npm registry

## Installation

To install NVM and Node.js:

```bash
./install.sh
```

The installation process includes:
1. Checking for existing NVM installation
2. Installing NVM using the official install script
3. Configuring shell profile (`.zshrc` or `.bashrc`)
4. Installing Node.js LTS version
5. Setting default Node.js version
6. Installing `.npmrc` configuration for JFrog Artifactory
7. Verifying installation

## Components Installed

### Core Components
- **NVM** - Node Version Manager (v0.40.3)
- **Node.js** - Latest LTS version
- **npm** - Node Package Manager (included with Node.js)
- **.npmrc** - npm configuration file for JFrog Artifactory registry

## Dependencies

- `curl` or `wget` - For downloading NVM install script
- `git` - For NVM to download Node.js versions (usually pre-installed)

The script will automatically install `curl` if neither `curl` nor `wget` is available.

## Post-Installation Steps

### 1. Reload Shell Configuration

After installation, reload your shell configuration:

```bash
source ~/.zshrc  # For zsh
# or
source ~/.bashrc  # For bash
```

Or simply open a new terminal window.

### 2. Verify Installation

Test NVM:

```bash
nvm --version
```

Test Node.js:

```bash
node --version
npm --version
```

### 3. Test Node.js Functionality

```bash
node -e "console.log('Hello from Node.js')"
```

### 4. Configure .npmrc for JFrog Artifactory

The `.npmrc` file is automatically installed and stowed to `$HOME/.npmrc`. You need to update the following placeholders with your actual credentials:

1. **Email**: Replace `your.email@itsf.io` with your actual ITSF email address
2. **Base64 Encoded Credentials**: Replace `YOUR_BASE64_ENCODED_CREDENTIALS` with your base64-encoded credentials
   - Generate with: `echo -n "username:password" | base64`
3. **Certificate Path**: Replace `/home/YOUR_USERNAME/.certs/root-ca.crt` with your actual certificate path
4. **JWT Token**: Replace `YOUR_JWT_TOKEN` with your actual JWT token from JFrog Artifactory

Edit the file:
```bash
nano ~/.npmrc
# or
vim ~/.npmrc
```

Verify the configuration:
```bash
cat ~/.npmrc
```

## Usage

### Basic NVM Commands

```bash
# List installed Node.js versions
nvm ls

# List available Node.js versions
nvm ls-remote

# Install a specific Node.js version
nvm install 20.10.0
nvm install 18.19.0
nvm install lts/*  # Install latest LTS

# Use a specific Node.js version
nvm use 20.10.0
nvm use default

# Set default Node.js version
nvm alias default 20.10.0
nvm alias default lts/*

# Show current Node.js version
nvm current

# Show Node.js version
node --version

# Show npm version
npm --version
```

### Installing Node.js Versions

```bash
# Install latest LTS version
nvm install --lts

# Install latest version
nvm install node

# Install specific version
nvm install 20.10.0
nvm install 18.19.0
nvm install 16.20.2
```

### Switching Between Versions

```bash
# Use a specific version
nvm use 20.10.0

# Use default version
nvm use default

# Use system version (if installed)
nvm use system
```

### Managing Versions

```bash
# List installed versions
nvm ls

# List available versions
nvm ls-remote

# List LTS versions only
nvm ls-remote --lts

# Uninstall a version
nvm uninstall 18.19.0
```

### Using .nvmrc Files

Create a `.nvmrc` file in your project directory:

```bash
echo "20.10.0" > .nvmrc
```

Then use:

```bash
nvm use
```

This will automatically switch to the version specified in `.nvmrc`.

## Configuration

### NVM Directory

NVM is installed in one of the following locations:
- `$HOME/.nvm` (default)
- `$XDG_CONFIG_HOME/nvm` (if `XDG_CONFIG_HOME` is set)

### .npmrc Configuration

The `.npmrc` file is configured for JFrog Artifactory npm registry. The file is stowed to `$HOME/.npmrc` and contains the following configuration:

```ini
email=your.email@itsf.io
always-auth=true
registry=https://jfrog-artifactory.steelhome.internal/artifactory/api/npm/itsffr-npm/

//jfrog-artifactory.steelhome.internal/artifactory/api/npm/itsffr-npm/:_auth="YOUR_BASE64_ENCODED_CREDENTIALS"

cafile=/home/YOUR_USERNAME/.certs/root-ca.crt

//jfrog-artifactory.steelhome.internal/artifactory/api/npm/itsffr-npm/:_authToken=YOUR_JWT_TOKEN
```

#### Configuration Parameters Explained

- **email**: Your ITSF email address used for authentication (format: `your.name@itsf.io`)
- **always-auth**: Ensures npm always sends authentication credentials, even for public packages (required for JFrog Artifactory access)
- **registry**: The base URL of the npm registry in JFrog Artifactory
- **_auth**: Base64-encoded credentials in the format `username:password`. Generate with: `echo -n "username:password" | base64`
- **cafile**: Path to the CA certificate file for SSL/TLS verification. Update with your actual home directory path and ensure the certificate file exists
- **_authToken**: JWT authentication token provided by JFrog Artifactory. This token is obtained after logging into JFrog Artifactory

**Important**: After installation, you must replace all placeholders in `$HOME/.npmrc` with your actual credentials before using npm.

### Shell Configuration

NVM is automatically configured in your shell profile:
- `~/.zshrc` (for zsh)
- `~/.bashrc` or `~/.bash_profile` (for bash)
- `~/.profile` (fallback)

The configuration includes:
```bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
```

## Troubleshooting

### NVM Command Not Found

If `nvm` command is not found after installation:

1. Reload your shell configuration:
   ```bash
   source ~/.zshrc  # or ~/.bashrc
   ```

2. Or open a new terminal window

3. Verify NVM is sourced:
   ```bash
   type nvm
   ```

### Node.js Not Found

If `node` command is not found:

1. Make sure NVM is loaded:
   ```bash
   source ~/.zshrc  # or ~/.bashrc
   ```

2. Check if Node.js is installed:
   ```bash
   nvm ls
   ```

3. Install Node.js if needed:
   ```bash
   nvm install --lts
   nvm use --lts
   ```

### Permission Issues

If you encounter permission issues:

1. Make sure you're not running as root
2. Check NVM directory permissions:
   ```bash
   ls -la ~/.nvm
   ```

3. Fix permissions if needed:
   ```bash
   chown -R $USER:$USER ~/.nvm
   ```

### Slow Installation

Node.js installation can be slow, especially when compiling from source. This is normal. The script will show progress during installation.

## Testing

Run the test script to verify installation:

```bash
./test.sh
```

The test script verifies:
- NVM directory and script existence
- NVM command availability
- Shell configuration
- Node.js and npm installation
- NVM default version
- Node.js and npm functionality

## Additional Resources

- [NVM GitHub Repository](https://github.com/nvm-sh/nvm)
- [NVM Documentation](https://github.com/nvm-sh/nvm/blob/master/README.md)
- [Node.js Official Website](https://nodejs.org/)
- [npm Documentation](https://docs.npmjs.com/)

## Notes

- NVM is installed per-user, not system-wide
- Each user needs to install NVM separately
- Node.js versions are installed in `$NVM_DIR/versions/node/`
- The default Node.js version is set during installation
- You can install multiple Node.js versions and switch between them
- npm is included with each Node.js installation

## Version Information

- **NVM Version**: v0.40.3
- **Node.js Version**: Latest LTS (automatically selected)
- **npm Version**: Included with Node.js

