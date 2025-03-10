#!/bin/bash

# Remove old versions of Docker if any
sudo dnf remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine \
                  podman \
                  runc

# Install necessary plugins for DNF
sudo dnf -y install dnf-plugins-core

# Add Docker's official repository
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

# Install Docker and related components
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Stop Docker service to prepare for directory change
sudo systemctl stop docker

# Move Docker directory to /data/docker
sudo cp -r /var/lib/docker /var/lib/docker.bak
sudo mv /var/lib/docker /data/

# Overwrite daemon.json with new configuration
echo '{
    "bip": "55.55.1.1/24",
    "data-root": "/data/docker"
}' | sudo tee /etc/docker/daemon.json

# Enable and start Docker service
sudo systemctl enable --now docker

# Verify Docker installation
sudo docker --version
sudo docker-compose --version

docker pull vanminhph23/rabbitmq:1.0

docker pull vanminhph23/centos7.java8.spring:1.5

docker pull vanminhph23/ubuntu.java17.spring:1.2
