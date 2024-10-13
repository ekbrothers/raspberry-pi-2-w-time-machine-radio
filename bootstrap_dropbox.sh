#!/bin/bash

# Dropbox Bootstrap Script for Raspberry Pi Time Machine Radio

# Check if rclone is installed
if ! command -v rclone &> /dev/null
then
    echo "rclone is not installed. Installing now..."
    sudo apt-get update && sudo apt-get install -y rclone
fi

# Prompt for username if not provided
if [ -z "$1" ]; then
    read -p "Enter your Raspberry Pi username: " USERNAME
else
    USERNAME=$1
fi

# Prompt for Dropbox access token
read -p "Enter your Dropbox access token: " DROPBOX_TOKEN

# Save Dropbox token securely
echo "$DROPBOX_TOKEN" > /home/$USERNAME/.dropbox_token
chmod 600 /home/$USERNAME/.dropbox_token

# Set up rclone
echo "Setting up rclone for Dropbox..."
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
rclone sync dropbox:radioTimeMachine /home/$USERNAME/audio --progress --exclude ".*" --log-file="/home/$USERNAME/rclone_sync.log"
echo "Sync completed at \$(date)" >> /home/$USERNAME/rclone_sync.log
EOF
chmod +x /home/$USERNAME/sync_dropbox.sh

# Set up cron job for hourly sync
echo "Setting up cron job for hourly sync..."
(crontab -l 2>/dev/null; echo "0 * * * * /home/$USERNAME/sync_dropbox.sh") | crontab -

# Run initial sync
echo "Running initial Dropbox sync..."
/home/$USERNAME/sync_dropbox.sh

echo "Dropbox setup complete. Your radioTimeMachine folder will sync hourly."