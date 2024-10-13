#!/bin/bash

# Main Bootstrap Script for Raspberry Pi Time Machine Radio

# Prompt for username
read -p "Enter your Raspberry Pi username: " USERNAME

# Run individual setup scripts
./system_setup.sh "$USERNAME"
./dropbox_bootstrap.sh "$USERNAME"
./repository_setup.sh "$USERNAME"
./audio_setup.sh
./service_setup.sh "$USERNAME"

echo "Setup complete. Rebooting in 10 seconds..."
sleep 10
sudo reboot