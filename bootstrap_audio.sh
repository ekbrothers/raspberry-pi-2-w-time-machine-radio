#!/bin/bash
USERNAME=$1

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

# Enable I2S interface
echo "Enabling I2S interface..."
sudo raspi-config nonint do_i2s 0

# Add user to audio group
echo "Adding user to audio group..."
sudo usermod -a -G audio $USERNAME

echo "Audio configuration complete."