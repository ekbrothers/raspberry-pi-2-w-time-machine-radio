#!/bin/bash
# Initial Bootstrap Script for Raspberry Pi Time Machine Radio
# This script downloads all other bootstrap scripts from the repository

REPO_URL="https://raw.githubusercontent.com/ekbrothers/raspberry-pi-2-w-time-machine-radio/main"
SCRIPTS=(
    "bootstrap_main.sh"
    "bootstrap_system.sh"
    "bootstrap_dropbox.sh"
    "bootstrap_python.sh"
    "bootstrap_audio.sh"
    "bootstrap_service.sh"
)

echo "Downloading bootstrap scripts..."
for script in "${SCRIPTS[@]}"; do
    curl -O "$REPO_URL/$script"
    chmod +x "$script"
    echo "Downloaded and made executable: $script"
done

echo "All bootstrap scripts have been downloaded."
echo "To start the setup process, run: sudo ./bootstrap_main.sh"