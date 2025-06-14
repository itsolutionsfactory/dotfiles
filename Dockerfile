FROM ubuntu:24.04

# Install sudo
RUN apt-get update && apt-get install -y sudo && rm -rf /var/lib/apt/lists/*

# Create test user and sudo configuration
RUN mkdir -p /etc/sudoers.d && \
    useradd -m -s /bin/bash testuser && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/testuser

# Set up working directory
WORKDIR /home/testuser

# Set correct permissions for the mounted directory
RUN chown -R testuser:testuser /home/testuser

# Copy entrypoint script
COPY --chown=testuser:testuser entrypoint.sh /home/testuser/
RUN chmod +x /home/testuser/entrypoint.sh

# Switch to test user
USER testuser

# Set the entrypoint
ENTRYPOINT ["/home/testuser/entrypoint.sh"]
CMD ["/bin/zsh"] 