#!/bin/bash

USERNAME=$1

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