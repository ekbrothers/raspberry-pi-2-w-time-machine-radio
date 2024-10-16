<!-- vscode-markdown-toc -->
* 1. [Table of Contents](#TableofContents)
* 2. [User Interactions](#UserInteractions)
* 3. [Repository Structure](#RepositoryStructure)
* 4. [Local Development](#LocalDevelopment)
* 5. [Workflows](#Workflows)
* 6. [Hardware Setup](#HardwareSetup)
* 7. [Deployment](#Deployment)
* 8. [Specifying the Correct Audio Device in Python](#SpecifyingtheCorrectAudioDeviceinPython)
* 9. [Development and Testing Stages](#DevelopmentandTestingStages)
	* 9.1. [1. Local Python Development on Raspberry Pi](#LocalPythonDevelopmentonRaspberryPi)
	* 9.2. [2. Local Container Build on Raspberry Pi](#LocalContainerBuildonRaspberryPi)
	* 9.3. [3. Full CI/CD Pipeline with Remote Container Registry](#FullCICDPipelinewithRemoteContainerRegistry)
	* 9.4. [Setting Up a Virtual Environment](#SettingUpaVirtualEnvironment)
	* 9.5. [Managing Dependencies](#ManagingDependencies)
	* 9.6. [Best Practices](#BestPractices)
	* 9.7. [Troubleshooting](#Troubleshooting)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->
# Raspberry Pi Time Machine Radio

This project implements a time-traveling radio using a Raspberry Pi Zero 2 W, allowing users to explore music from different decades using potentiometers for control.

##  1. <a name='TableofContents'></a>Table of Contents

- [User Interactions](#user-interactions)
- [Repository Structure](#repository-structure)
- [Local Development](#local-development)
- [Workflows](#workflows)
- [Hardware Setup](#hardware-setup)
- [Setting up the BossDAC](#setting-up-the-bossdac)
- [Deployment](#deployment)

##  2. <a name='UserInteractions'></a>User Interactions

1. **Power On/Off**: 
   - Turn the left potentiometer to its far counterclockwise position to toggle the power state of the radio.

2. **Volume Adjustment**:
   - Rotate the left potentiometer clockwise from its starting position to increase volume.
   - Rotate the left potentiometer counterclockwise (but not to the far end) to decrease volume.

3. **Decade Selection** (when powered off):
   - Rotate the right potentiometer to cycle through tracks within each decade.
   - Turn the right potentiometer to its far counterclockwise position and then back to change the decade.

4. **Track Navigation** (when powered on):
   - Rotate the right potentiometer clockwise to move to the next track.
   - Rotate the right potentiometer counterclockwise (but not to the far end) to move to the previous track.

5. **Change Decade** (when powered on):
   - Turn the right potentiometer to its far counterclockwise position and then turn clockwise again to change the decade, triggering the "time travel" effect.

6. **Time Travel Effect**:
   - When changing decades (following the process in step 5), a special audio and/or visual effect will be triggered to enhance the "time travel" experience.

Note: The far counterclockwise position of each potentiometer acts as a switch, triggering specific actions like power on/off or decade changes.

##  6. <a name='HardwareSetup'></a>Hardware Setup

- Raspberry Pi Zero 2 W
- BossDAC (ALLO BOSS DAC PCM5122)
- 2 potentiometers with built-in switches:
  - Left potentiometer: Volume control and power on/off
  - Right potentiometer: Track selection and decade change
- Speaker (connected to the DAC HAT)

GPIO Connections:
- Left Potentiometer:
  - CLK: GPIO 17
  - DT: GPIO 18
  - SW: GPIO 27
- Right Potentiometer:
  - CLK: GPIO 22
  - DT: GPIO 23
  - SW: GPIO 24


###  9.4. <a name='SettingUpaVirtualEnvironment'></a>Setting Up a Virtual Environment

1. **Install venv** (if not already available):
   ```bash
   sudo apt-get update
   sudo apt-get install python3-venv
   ```

2. **Create a new virtual environment**:
   Navigate to your project directory and run:
   ```bash
   python3 -m venv venv
   ```
   This creates a new directory called `venv` in your project folder.

3. **Activate the virtual environment**:
   ```bash
   source venv/bin/activate
   ```
   Your prompt should change to indicate that the virtual environment is active.

4. **Install required packages**:
   With the virtual environment activated, install your project's dependencies:
   ```bash
   pip install sounddevice numpy soundfile requests
   ```
   Or if you have a `requirements.txt` file:
   ```bash
   pip install -r requirements.txt
   ```

5. **Deactivate the virtual environment**:
   When you're done working on your project, you can deactivate the virtual environment:
   ```bash
   deactivate
   ```


# Raspberry Pi Time Machine Radio Provisioning Guide

This guide will walk you through the process of setting up your Raspberry Pi for the Time Machine Radio project using our custom bootstrap scripts.

## Prerequisites

- Raspberry Pi (preferably Raspberry Pi Zero 2 W)
- SD card with fresh Raspberry Pi OS installation
- Internet connection
- Dropbox account and access token (for music syncing)

## Getting Started

1. **Boot your Raspberry Pi**:
   - Insert the SD card with Raspberry Pi OS into your Raspberry Pi.
   - Connect power and wait for it to boot.

2. **Initial Setup**:
   - Complete the initial Raspberry Pi setup (set password, configure Wi-Fi, etc.).
   - Open a terminal window.

3. **Download the Initial Bootstrap Script**:
   Run the following command to download the initial bootstrap script:
   ```bash
   curl -O https://raw.githubusercontent.com/ekbrothers/raspberry-pi-2-w-time-machine-radio/main/bootstrap_init.sh
   chmod +x bootstrap_init.sh
   ```

4. **Run the Initial Bootstrap Script**:
   Execute the script to download all other necessary scripts:
   ```bash
   ./bootstrap_init.sh
   ```
   This script will download:
   - bootstrap_main.sh
   - bootstrap_system.sh
   - bootstrap_dropbox.sh
   - bootstrap_python.sh
   - bootstrap_audio.sh
   - bootstrap_service.sh

5. **Run the Main Bootstrap Script**:
   After the initial script completes, run the main bootstrap script:
   ```bash
   sudo ./bootstrap_main.sh
   ```
   This script will:
   - Prompt for your Raspberry Pi username
   - Run all other bootstrap scripts in the correct order
   - Reboot the Raspberry Pi when setup is complete

6. **Follow Prompts**:
   During the execution of the scripts, you may be prompted for additional information:
   - Your Raspberry Pi username (if not already provided)
   - Your Dropbox access token (for music syncing)

## What the Scripts Do

- **bootstrap_system.sh**: Updates the system and installs necessary packages.
- **bootstrap_dropbox.sh**: Sets up rclone for Dropbox syncing and creates a sync script and cron job.
- **bootstrap_python.sh**: Clones the project repository and sets up a Python virtual environment.
- **bootstrap_audio.sh**: Configures audio settings for the DAC (Digital-to-Analog Converter).
- **bootstrap_service.sh**: Creates and enables a system service for the Time Machine Radio.

## After Setup

Once the setup is complete and your Raspberry Pi has rebooted:

1. The Time Machine Radio service should start automatically.
2. Your Dropbox "radioTimeMachine" folder will sync hourly to `/home/your_username/audio`.
3. You can check the status of the service by running:
   ```bash
   sudo systemctl status time_machine_radio.service
   ```

## Troubleshooting

If you encounter any issues:

1. Check the system logs:
   ```bash
   journalctl -u time_machine_radio.service
   ```

2. Verify that all scripts were executed successfully by checking for any error messages in the terminal output.

3. Ensure your Dropbox token is correct and that the "radioTimeMachine" folder exists in your Dropbox.

4. If you have audio issues, make sure your DAC is properly connected and recognized by the system.

## Manual Adjustments

You may need to make manual adjustments depending on your specific hardware setup or requirements. Refer to the individual script contents for details on what each script does and where you might need to make changes.

## Updating the Project

To update the project in the future:

1. Navigate to the project directory:
   ```bash
   cd /home/your_username/time_machine_radio
   ```

2. Pull the latest changes:
   ```bash
   git pull origin main
   ```

3. Rerun the bootstrap scripts if necessary, or manually apply any new configuration changes.

Remember to replace `your_username` with your actual Raspberry Pi username in all paths and commands.