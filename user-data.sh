#!/bin/bash
# Update the package manager and install necessary tools
yum update -y

# Install Docker
amazon-linux-extras install docker -y

# Start Docker service
service docker start

# Enable Docker to start on boot
systemctl enable docker

# Install Git
yum install git -y

# Optional: Add any additional installation steps here
# e.g., Install JFrog CLI, AWS CLI, etc.
