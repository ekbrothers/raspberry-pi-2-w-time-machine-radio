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

echo "Python environment setup complete."