# Docker

This module manages the installation of Docker Engine, CLI, containerd, and Docker Compose on Ubuntu 24 LTS using Docker's official apt repository.

## Features

- Installation of Docker Engine from official Docker repository
- Installation of Docker CLI, containerd, and Docker Compose
- Automatic repository setup with GPG key verification
- Docker daemon management and auto-start configuration
- Comprehensive installation verification
- Post-installation guidance

## Installation

To install Docker:

```bash
sudo ./install.sh
```

The installation process includes:
1. Removing old Docker versions (if any)
2. Installing prerequisites (ca-certificates, curl, gnupg, lsb-release)
3. Adding Docker's official GPG key
4. Setting up Docker's apt repository
5. Installing Docker Engine, CLI, containerd, and Docker Compose
6. Starting and enabling Docker daemon
7. Verifying installation with hello-world image

## Components Installed

### Core Components
- **docker-ce** - Docker Engine Community Edition
- **docker-ce-cli** - Docker Command Line Interface
- **containerd.io** - Container runtime
- **docker-buildx-plugin** - Extended build capabilities
- **docker-compose-plugin** - Docker Compose V2 plugin

## Post-Installation Steps

### 1. Add User to Docker Group

To run Docker commands without `sudo`, add your user to the docker group:

```bash
sudo usermod -aG docker $USER
```

Then log out and log back in for the changes to take effect.

### 2. Verify Installation

Test Docker without sudo:

```bash
docker run hello-world
```

### 3. Verify Docker Compose

```bash
docker compose version
```

## Usage

### Basic Docker Commands

```bash
# Run a container
docker run hello-world

# List running containers
docker ps

# List all containers
docker ps -a

# List images
docker images

# Pull an image
docker pull ubuntu:24.04

# Run an interactive container
docker run -it ubuntu:24.04 /bin/bash

# Remove a container
docker rm <container_id>

# Remove an image
docker rmi <image_id>
```

### Docker Compose

```bash
# Start services
docker compose up

# Start services in detached mode
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs

# Build images
docker compose build
```

### Container Management

```bash
# Start a container
docker start <container_id>

# Stop a container
docker stop <container_id>

# Restart a container
docker restart <container_id>

# View container logs
docker logs <container_id>

# Execute command in running container
docker exec -it <container_id> /bin/bash
```

### Image Management

```bash
# Build an image from Dockerfile
docker build -t myimage:tag .

# Tag an image
docker tag myimage:tag myimage:latest

# Push an image to registry
docker push myimage:tag

# Remove unused images
docker image prune

# Remove all unused images
docker image prune -a
```

## Configuration

### Docker Client Configuration

Docker client configuration is managed via stow and located at:
- `$HOME/.docker/config.json` - Docker client configuration file (symlinked via stow)

The default configuration includes JFrog Artifactory authentication:

```json
{
	"auths": {
		"jfrog-artifactory.steelhome.internal:443": {
			"auth": "token from jfrog",
			"email": "name.lastename@itsf.io"
		}
	}
}
```

**Important:** After installation, you must update the token in `$HOME/.docker/config.json`:
1. Replace `"token from jfrog"` with your actual JFrog Artifactory token
2. Update the email address if needed

The configuration is managed via stow, so changes should be made in the module directory:
- Source: `docker/.docker/config.json`
- Target: `$HOME/.docker/config.json` (symlink)

### Docker Daemon Configuration

Docker daemon configuration is located at:
- `/etc/docker/daemon.json` - Main daemon configuration file

Example configuration:

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
```

After modifying the configuration, restart Docker:

```bash
sudo systemctl restart docker
```

### Docker Compose Configuration

Docker Compose uses `docker-compose.yml` or `compose.yml` files:

```yaml
version: '3.8'

services:
  web:
    image: nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./html:/usr/share/nginx/html
```

## Security Considerations

### 1. Docker Group Security

Adding users to the docker group grants them root-equivalent privileges. Only add trusted users:

```bash
# Add user to docker group
sudo usermod -aG docker username

# Verify group membership
groups username
```

### 2. Rootless Mode

For enhanced security, consider using Docker in rootless mode:

```bash
# Install rootless Docker
dockerd-rootless-setuptool.sh install

# Start rootless Docker
systemctl --user start docker
```

### 3. Content Trust

Enable Docker Content Trust for image verification:

```bash
export DOCKER_CONTENT_TRUST=1
```

### 4. Network Security

- Use Docker networks to isolate containers
- Implement firewall rules for exposed ports
- Use secrets management for sensitive data

## Troubleshooting

### Common Issues

1. **Permission Denied Errors:**
   ```bash
   # Add user to docker group
   sudo usermod -aG docker $USER
   # Log out and log back in
   ```

2. **Docker Daemon Not Running:**
   ```bash
   # Check daemon status
   sudo systemctl status docker
   
   # Start daemon
   sudo systemctl start docker
   
   # Enable auto-start
   sudo systemctl enable docker
   ```

3. **Cannot Connect to Docker Daemon:**
   ```bash
   # Check if daemon is running
   sudo systemctl status docker
   
   # Check Docker socket permissions
   ls -l /var/run/docker.sock
   ```

4. **Repository Issues:**
   ```bash
   # Update package list
   sudo apt-get update
   
   # Verify repository configuration
   cat /etc/apt/sources.list.d/docker.list
   
   # Check GPG key
   ls -l /etc/apt/keyrings/docker.gpg
   ```

5. **Image Pull Failures:**
   ```bash
   # Check network connectivity
   ping registry-1.docker.io
   
   # Configure proxy if needed
   sudo mkdir -p /etc/systemd/system/docker.service.d
   # Add proxy configuration
   ```

### Debugging

```bash
# View Docker daemon logs
sudo journalctl -u docker

# View Docker system information
docker info

# Check Docker version
docker version

# Test Docker installation
docker run hello-world
```

## Upgrading Docker

To upgrade Docker to a newer version:

```bash
# Update package list
sudo apt-get update

# Upgrade Docker packages
sudo apt-get upgrade docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Or re-run the installation script, which will upgrade to the latest version.

## Uninstalling Docker

To uninstall Docker:

```bash
# Uninstall Docker packages
sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras

# Remove images, containers, volumes
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

# Remove repository configuration
sudo rm /etc/apt/sources.list.d/docker.list
sudo rm /etc/apt/keyrings/docker.gpg
```

## Best Practices

### 1. Resource Management

```bash
# Set resource limits for containers
docker run --memory="512m" --cpus="1.0" myimage

# Monitor resource usage
docker stats
```

### 2. Data Persistence

```bash
# Use volumes for persistent data
docker volume create myvolume
docker run -v myvolume:/data myimage

# Use bind mounts for development
docker run -v /host/path:/container/path myimage
```

### 3. Networking

```bash
# Create custom networks
docker network create mynetwork

# Connect containers to network
docker run --network mynetwork myimage
```

### 4. Image Optimization

- Use multi-stage builds
- Minimize image layers
- Use .dockerignore files
- Remove unnecessary packages

### 5. Security

- Regularly update Docker and images
- Scan images for vulnerabilities
- Use minimal base images
- Implement proper access controls

## Related Documentation

- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Engine Installation Guide](https://docs.docker.com/engine/install/ubuntu/)
- [Docker Post-Installation Steps](https://docs.docker.com/engine/install/linux-postinstall/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)

## Notes

- Docker requires kernel version 3.10 or higher (Ubuntu 24.04 includes 6.x kernel)
- Docker daemon runs as root by default
- Consider using rootless mode for enhanced security
- Docker Compose V2 is installed as a plugin (use `docker compose` not `docker-compose`)
- The installation script follows Docker's official installation instructions for Ubuntu

