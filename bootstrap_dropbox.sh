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

# Instructions for obtaining Dropbox access token
echo "To obtain a Dropbox access token, follow these steps on another machine:"
echo "1. Install rclone if not already installed (https://rclone.org/install/)"
echo "2. Open a terminal and run: rclone config"
echo "3. Choose 'n) New remote'"
echo "4. Name it 'dropbox' (or any name you prefer)"
echo "5. Choose 'Dropbox' as the storage type"
echo "6. Leave the Dropbox App Key and Secret blank (press Enter)"
echo "7. Answer 'n' to edit advanced config and 'y' to use auto config"
echo "8. A browser window will open. Log in to Dropbox and authorize rclone"
echo "9. Once authorized, return to the terminal and choose 'q' to quit config"
echo "10. Run: rclone config show"
echo "11. Find the 'token' value in the output. This is your Dropbox access token"
echo ""
echo "After obtaining the token, you can continue with this script."
echo ""

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
token = $DROPBOX_TOKEN
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