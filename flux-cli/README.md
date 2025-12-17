# Flux CLI Configuration

This module provides installation and setup for Flux CLI, the GitOps toolkit for Kubernetes.

## Features

- Flux CLI installation (latest version)
- Automatic OS and architecture detection (Linux/macOS, amd64/arm64)
- ZSH completion support
- Automatic version checking
- Clean installation process

## What is Flux?

Flux is a set of continuous and progressive delivery solutions for Kubernetes that are open and extensible. It allows you to:

- Automate deployment of applications to Kubernetes clusters
- Keep clusters in sync with configuration sources (Git repositories)
- Provide GitOps workflow for Kubernetes
- Manage Helm releases and Kubernetes manifests
- Support multi-tenancy and RBAC

## Installation

To install the Flux CLI:

```bash
cd flux-cli
./install.sh
```

The installation process includes:
1. Detecting your OS and architecture
2. Fetching the latest Flux CLI version from GitHub
3. Downloading and installing the appropriate binary
4. Setting up ZSH completion (if Oh My ZSH is installed)
5. Verifying the installation

## Testing

To verify the installation:

```bash
./test.sh
```

## Usage

After installation, you can use the `flux` command:

```bash
# Check version
flux version

# Bootstrap Flux on a cluster
flux bootstrap github \
  --owner=<your-username> \
  --repository=<repository-name> \
  --path=clusters/my-cluster \
  --personal

# Check Flux system status
flux check

# Get all Flux resources
flux get all

# Reconcile a source
flux reconcile source git <source-name>
```

## Requirements

- `curl` for downloading files
- `sudo` access for system-wide installation
- Kubernetes cluster (for actual Flux operations)
- Git repository (for GitOps workflow)

## Links

- [Flux Documentation](https://fluxcd.io/docs/)
- [Flux GitHub Repository](https://github.com/fluxcd/flux2)
- [Getting Started Guide](https://fluxcd.io/docs/get-started/)
