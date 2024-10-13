#!/bin/bash

# Raspberry Pi Time Machine Radio Bootstrap Script
#
# This script sets up the Raspberry Pi for the Time Machine Radio project.
#
# Startup Steps:
# 1. Ensure your Raspberry Pi is connected to the internet.
# 2. Open a terminal on your Raspberry Pi.
# 3. Run the following commands:
#    curl -O https://raw.githubusercontent.com/ekbrothers/raspberry-pi-2-w-time-machine-radio/main/bootstrap.sh
#    chmod +x bootstrap.sh
#    sudo ./bootstrap.sh
# 4. Follow the prompts to enter your Raspberry Pi username and Dropbox access token.
# 5. The script will then automatically set up your Raspberry Pi and reboot when finished.
#
# What this script does:
# - Prompts for and securely stores the Dropbox access token
# - Updates and upgrades the system
# - Installs necessary packages (rclone, Python, git, etc.)
# - Sets up rclone for Dropbox syncing
# - Creates a sync script and sets up a cron job for hourly syncing
# - Clones the Time Machine Radio repository
# - Sets up a Python virtual environment and installs requirements
# - Configures audio for the BossDAC
# - Creates and enables a systemd service for the Time Machine Radio
# - Reboots the Raspberry Pi to apply all changes

# Bootstrap script for Raspberry Pi Time Machine Radio

# Prompt for username
read -p "Enter your Raspberry Pi username: " USERNAME

# Prompt for Dropbox access token
read -p "Enter your Dropbox access token: " DROPBOX_TOKEN

# Save Dropbox token securely
echo "$DROPBOX_TOKEN" > /home/$USERNAME/.dropbox_token
chmod 600 /home/$USERNAME/.dropbox_token

# Update and upgrade the system
echo "Updating and upgrading the system..."
sudo apt-get update && sudo apt-get upgrade -y

# Install necessary packages
echo "Installing necessary packages..."
sudo apt-get install -y rclone python3-venv python3-pip sox git

# Set up rclone
echo "Setting up rclone..."
mkdir -p /home/$USERNAME/.config/rclone

cat << EOF > /home/$USERNAME/.config/rclone/rclone.conf
[dropbox]
type = dropbox
token = {"access_token":"$DROPBOX_TOKEN","token_type":"bearer","expiry":"0001-01-01T00:00:00Z"}
EOF

# Create sync script
echo "Creating Dropbox sync script..."
cat << EOF > /home/$USERNAME/sync_dropbox.sh
#!/bin/bash
rclone sync dropbox:radioTimeMachine /home/$USERNAME/audio --progress --recursive --exclude ".*" --log-file="/home/$USERNAME/rclone_sync.log"
echo "Sync completed at \$(date)" >> /home/$USERNAME/rclone_sync.log
EOF
chmod +x /home/$USERNAME/sync_dropbox.sh

# Set up cron job for hourly sync
echo "Setting up cron job for hourly sync..."
(crontab -l 2>/dev/null; echo "0 * * * * /home/$USERNAME/sync_dropbox.sh") | crontab -

# Clone the Time Machine Radio repository
echo "Cloning the Time Machine Radio repository..."
git clone https://github.com/ekbrothers/raspberry-pi-2-w-time-machine-radio.git /home/$USERNAME/time_machine_radio

# Set up Python virtual environment
echo "Setting up Python virtual environment..."
python3 -m venv /home/$USERNAME/time_machine_radio/venv
source /home/$USERNAME/time_machine_radio/venv/bin/activate
pip install -r /home/$USERNAME/time_machine_radio/requirements.txt

# Configure audio
echo "Configuring audio..."
sudo sed -i '$a\dtoverlay=allo-boss-dac-pcm512x-audio' /boot/config.txt
sudo sed -i '$a\dtparam=i2s=on' /boot/config.txt
sudo sed -i 's/^dtparam=audio=on/#dtparam=audio=on/' /boot/config.txt

# Create a service file for the Time Machine Radio
echo "Creating a service file for the Time Machine Radio..."
cat << EOF | sudo tee /etc/systemd/system/time_machine_radio.service
[Unit]
Description=Time Machine Radio
After=network.target

[Service]
ExecStart=/home/$USERNAME/time_machine_radio/venv/bin/python /home/$USERNAME/time_machine_radio/src/main.py
WorkingDirectory=/home/$USERNAME/time_machine_radio
StandardOutput=inherit
StandardError=inherit
Restart=always
User=$USERNAME

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the Time Machine Radio service
sudo systemctl enable time_machine_radio.service
sudo systemctl start time_machine_radio.service

echo "Setup complete. Rebooting in 10 seconds..."
sleep 10
sudo reboot