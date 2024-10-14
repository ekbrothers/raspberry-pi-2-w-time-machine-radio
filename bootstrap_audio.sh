#!/bin/bash

USERNAME=$1

# Clone the Time Machine Radio repository
echo "Cloning the Time Machine Radio repository..."
git clone https://github.com/ekbrothers/raspberry-pi-2-w-time-machine-radio.git /home/$USERNAME/time_machine_radio

# Set up Python virtual environment
echo "Setting up Python virtual environment..."
python3 -m venv /home/$USERNAME/time_machine_radio/venv
source /home/$USERNAME/time_machine_radio/venv/bin/activate
pip install -r /home/$USERNAME/time_machine_radio/requirements.txt

# Configure audio for the DAC
echo "Configuring audio for the DAC..."

# Backup the original config.txt file
sudo cp /boot/firmware/config.txt /boot/config.txt.bak

# Add DAC configuration to config.txt
echo "Adding DAC configuration to /boot/config.txt..."
sudo tee -a /boot/config.txt > /dev/null << EOL

# DAC Configuration
dtoverlay=hifiberry-dac
dtparam=i2s=on
EOL

# Comment out the default audio configuration if it exists
sudo sed -i 's/^dtparam=audio=on/#dtparam=audio=on/' /boot/config.txt

# # Create ALSA configuration file
# echo "Creating ALSA configuration file..."
# sudo tee /etc/asound.conf > /dev/null << EOL
# pcm.!default {
#   type hw
#   card 1
# }

# ctl.!default {
#   type hw
#   card 1
# }
# EOL

# Enable I2S interface
echo "Enabling I2S interface..."
sudo raspi-config nonint do_i2s 0

# Add user to audio group
echo "Adding user to audio group..."
sudo usermod -a -G audio $USERNAME

echo "Audio configurati