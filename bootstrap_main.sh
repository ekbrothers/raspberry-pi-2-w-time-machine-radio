#!/bin/bash
# Main Bootstrap Script for Raspberry Pi Time Machine Radio

# Prompt for username
read -p "Enter your Raspberry Pi username: " USERNAME

# Run individual setup scripts
./bootstrap_system.sh "$USERNAME"
./bootstrap_dropbox.sh "$USERNAME"
./bootstrap_python.sh "$USERNAME"
./bootstrap_audio.sh "$USERNAME"
./bootstrap_service.sh "$USERNAME"

echo "Setup complete. Rebooting in 10 seconds..."
sleep 10
sudo reboot