#!/bin/bash

USERNAME=$1

# Update and upgrade the system
echo "Updating and upgrading the system..."
sudo apt-get update && sudo apt-get upgrade -y

# Install necessary packages
echo "Installing necessary packages..."
sudo apt-get install -y rclone python3-venv python3-pip sox git