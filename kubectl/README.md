# Kubectl Configuration

This module provides configuration and setup for kubectl, the Kubernetes command-line tool.

## Features

- kubectl installation and configuration
- kubelogin for OIDC authentication
- kubectl aliases and shortcuts
- kubectl completion for ZSH
- kubectl plugins support
- Multiple cluster support
- Automatic configuration backup

## Installation

To install the kubectl configuration:

```bash
cd kubectl
./install.sh
```

The installation process includes:
1. Installing kubectl if not present
2. Installing kubelogin for OIDC authentication
3. Setting up configuration directories
4. Backing up existing configuration
5. Installing ZSH completion
6. Creating necessary symlinks

## Configuration

The configuration includes:

- Multiple cluster support (Production and Staging)
- OIDC authentication setup
- kubectl aliases for common operations
- ZSH completion for kubectl commands
- kubectl plugins directory setup
- kubeconfig management

### Cluster Configuration

The module supports multiple clusters:
- Production cluster (NJJ-K8SV3-PRD)
- Staging cluster (NJJ-K8SV3-STG)

### Authentication

OIDC authentication is configured with:
- Automatic token refresh
- Secure credential management
- Interactive authentication mode

## Usage

After installation, you can use kubectl with the following features:

- Tab completion for all kubectl commands
- Short aliases for common operations
- Plugin support for extended functionality
- Easy context switching between clusters
- Namespace management
- OIDC authentication

### Context Switching

```bash
# Switch to production context
kubectl config use-context v3-prd

# Switch to staging context
kubectl config use-context v3-stg
```

### Testing

To verify the installation and configuration:

```bash
./test.sh
```

The test script will check:
- kubectl and kubelogin installation
- Configuration file presence and validity
- Cluster access
- OIDC authentication setup

## Requirements

- kubectl
- kubelogin (for OIDC authentication)
- ZSH shell
- GNU Stow 