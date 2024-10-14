# locally: rclone.exe authorize dropbox

curl -O https://raw.githubusercontent.com/ekbrothers/raspberry-pi-2-w-time-machine-radio/main/bootstrap_init.sh
chmod +x bootstrap_init.sh
sudo ./bootstrap_init.sh
#!/bin/bash

# Initial Bootstrap Script for Raspberry Pi Time Machine Radio
# This script downloads all other bootstrap scripts from the repository

REPO_URL="https://raw.githubusercontent.com/ekbrothers/raspberry-pi-2-w-time-machine-radio/main"
SCRIPTS=(
    "bootstrap_main.sh"
    "bootstrap_system.sh"
    "bootstrap_dropbox.sh"
    "bootstrap_repository.sh"
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