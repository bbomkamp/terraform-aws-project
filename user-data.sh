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

# Install logging utilities
yum install -y awslogs

# Configure AWS CloudWatch Logs to monitor system logs (make sure you have the CloudWatch agent installed on the instance)
cat <<EOL >> /etc/awslogs/awslogs.conf
[general]
state_file = /var/lib/awslogs/agent-state

[/var/log/messages]
file = /var/log/messages
log_group_name = EC2-LogGroup
log_stream_name = {instance_id}/var/log/messages
datetime_format = %b %d %H:%M:%S
EOL

# Start the CloudWatch Logs agent
service awslogs start
systemctl enable awslogs

# Install JFrog CLI
curl -fL https://getcli.jfrog.io | sh
mv jfrog /usr/local/bin

# Install AWS CLI
yum install -y aws-cli

# Install JFrog Xray (or configure Xray CLI)
# Note: For Xray, you might need to install dependencies or configure access to an instance.
# Example (if using Xray CLI):
jfrog rt config --url=<your-jfrog-url> --user=<your-username> --apikey=<your-api-key>

# Install and configure JFrog Artifactory
# Assuming you're installing the Artifactory OSS for learning purposes
curl -L https://bintray.com/jfrog/artifactory-rpms/download_file?file_path=latest/centos/jfrog-artifactory-oss-7.12.5.rpm -o jfrog-artifactory-oss.rpm
yum localinstall -y jfrog-artifactory-oss.rpm
service artifactory start
systemctl enable artifactory

# Optional: Install other useful tools
# For example, Python for scripting or additional DevOps automation tools
yum install -y python3
