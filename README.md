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

# Hardware Setup

## Components

- Raspberry Pi Zero 2 W
- Innomaker Raspberry Pi HiFi DAC MINI HAT (PCM5122)
- 2 rotary potentiometers with built-in switches:
  - Left potentiometer: Volume control and power on/off
  - Right potentiometer: Track selection and decade change
- Speaker (connected to the DAC HAT)
- ADC chip (MCP3008) for analog to digital conversion

## GPIO Connections

### 1. Left Potentiometer (Volume/Power)

| Function | Description | Raspberry Pi Pin | GPIO Number |
|----------|-------------|------------------|-------------|
| VCC | Power supply for potentiometer | Pin 1 | 3.3V |
| GND | Ground for potentiometer | Pin 6 | GND |
| WIPER | Variable voltage output | Pin 7 | GPIO 4 (connects to ADC) |
| SW1 | One side of the switch | Pin 13 | GPIO 27 |
| SW2 | Other side of the switch | Pin 14 | GND |

### 2. Right Potentiometer (Track/Decade)

| Function | Description | Raspberry Pi Pin | GPIO Number |
|----------|-------------|------------------|-------------|
| VCC | Power supply for potentiometer | Pin 17 | 3.3V |
| GND | Ground for potentiometer | Pin 20 | GND |
| WIPER | Variable voltage output | Pin 29 | GPIO 5 (connects to ADC) |
| SW1 | One side of the switch | Pin 18 | GPIO 24 |
| SW2 | Other side of the switch | Pin 25 | GND |

### 3. ADC Chip (MCP3008)

| Function | Description | Raspberry Pi Pin | GPIO Number |
|----------|-------------|------------------|-------------|
| VDD | Power supply | Pin 1 | 3.3V |
| VREF | Reference voltage | Pin 1 | 3.3V |
| AGND | Analog ground | Pin 9 | GND |
| CLK | SPI Clock | Pin 23 | GPIO 11 (SCLK) |
| DOUT | Data Out (MISO) | Pin 21 | GPIO 9 (MISO) |
| DIN | Data In (MOSI) | Pin 19 | GPIO 10 (MOSI) |
| CS | Chip Select | Pin 24 | GPIO 8 (CE0) |
| DGND | Digital ground | Pin 25 | GND |

### 4. Innomaker HiFi DAC MINI HAT (PCM5122)

The DAC HAT should be seated directly on the GPIO header of the Raspberry Pi Zero 2 W.

It uses the following interfaces:

#### I2S (Inter-IC Sound) Interface

| Function | Description | Raspberry Pi Pin | GPIO Number |
|----------|-------------|------------------|-------------|
| PCM_CLK (BCLK) | Bit Clock for audio data transmission | Pin 12 | GPIO 18 |
| PCM_FS (LRCLK) | Left/Right Clock for audio channel selection | Pin 35 | GPIO 19 |
| PCM_DIN (Data in) | Data input for audio signal | Pin 38 | GPIO 20 |
| PCM_DOUT (Data out) | Data output for audio signal | Pin 40 | GPIO 21 |

#### I2C (Inter-Integrated Circuit) Interface (for control)

| Function | Description | Raspberry Pi Pin | GPIO Number |
|----------|-------------|------------------|-------------|
| SDA (Serial Data) | Data line for I2C communication | Pin 3 | GPIO 2 |
| SCL (Serial Clock) | Clock line for I2C communication | Pin 5 | GPIO 3 |

### 5. Speaker

Connect to the appropriate output terminals on the Innomaker DAC HAT. Refer to the DAC HAT documentation for specific terminal locations.

## Important Notes for Python Script

1. Initialize GPIO mode:
   ```python
   import RPi.GPIO as GPIO
   GPIO.setmode(GPIO.BCM)
   ```

2. Set up switch GPIO pins with pull-up resistors:
   ```python
   GPIO.setup(27, GPIO.IN, pull_up_down=GPIO.PUD_UP)  # Left potentiometer switch
   GPIO.setup(24, GPIO.IN, pull_up_down=GPIO.PUD_UP)  # Right potentiometer switch
   ```

3. Set up SPI for the MCP3008:
   ```python
   import spidev
   spi = spidev.SpiDev()
   spi.open(0, 0)  # Bus 0, Device 0
   spi.max_speed_hz = 1000000  # 1MHz
   ```

4. Read analog values from MCP3008:
   ```python
   def read_adc(channel):
       adc = spi.xfer2([1, (8 + channel) << 4, 0])
       data = ((adc[1] & 3) << 8) + adc[2]
       return data
   
   # Left potentiometer on channel 0, Right on channel 1
   left_value = read_adc(0)
   right_value = read_adc(1)
   ```

5. Implement debouncing for switches in your script to avoid false triggers.

6. Remember to clean up GPIO on script exit:
   ```python
   GPIO.cleanup()
   ```

7. For the DAC HAT, you'll likely need to use specific audio libraries or system configurations. Refer to the Innomaker documentation for details on setting up audio output.

## Dropbox Sync Structure

The Time Machine Radio project uses Dropbox to sync music files to the Raspberry Pi, utilizing rclone for the synchronization process. This structure allows for a flexible organization of music into various categories, including decades and specific events.

### Sync Folder Location

The Dropbox sync folder on the Raspberry Pi is located at:

```
/home/[USERNAME]/audio
```

Where `[USERNAME]` is the username you provided during the setup process.

### Dropbox Folder Structure

In your Dropbox account, create a folder named `radioTimeMachine`. Inside this folder, create subfolders for each category you want. These can be decades, specific events, or any other categorization that fits your music collection. For example:

```
Dropbox/
└── radioTimeMachine/
    ├── 1950s/
    │   ├── song1.mp3
    │   ├── song2.mp3
    │   └── ...
    ├── 1960s/
    │   ├── song1.mp3
    │   ├── song2.mp3
    │   └── ...
    ├── Pearl Harbor/
    │   ├── newsreel1.mp3
    │   ├── song1.mp3
    │   └── ...
    ├── Summer of '69/
    │   ├── song1.mp3
    │   ├── song2.mp3
    │   └── ...
    └── ...
```

This structure will be mirrored in the `/home/[USERNAME]/audio` folder on your Raspberry Pi after syncing.

### Sync Configuration

1. The sync is managed by rclone, which is set up during the bootstrap process.
2. A sync script is created at `/home/[USERNAME]/sync_dropbox.sh`.
3. A cron job is set up to run this sync script hourly.

### Important Notes for Python Script

1. When initializing your Python script, set the base path for the music library:

   ```python
   import os
   
   USERNAME = os.getenv('USER')  # Gets the current username
   MUSIC_LIBRARY_PATH = f"/home/{USERNAME}/audio"
   ```

2. To get a list of all categories:

   ```python
   categories = [d for d in os.listdir(MUSIC_LIBRARY_PATH) if os.path.isdir(os.path.join(MUSIC_LIBRARY_PATH, d))]
   ```

3. To get songs for a specific category:

   ```python
   def get_songs_for_category(category):
       category_path = os.path.join(MUSIC_LIBRARY_PATH, category)
       return [f for f in os.listdir(category_path) if f.endswith('.mp3')]
   ```

4. To handle the flexible structure in your main script:

   ```python
   def select_category(potentiometer_value):
       # Map potentiometer value to category index
       index = int(potentiometer_value / (1024 / len(categories)))
       return categories[index]

   def play_from_category(category):
       songs = get_songs_for_category(category)
       if songs:
           # Logic to select and play a song from the category
           pass
       else:
           print(f"No songs found in category: {category}")
   ```

5. Your script should handle cases where the sync might be in progress or where a category folder might be empty.

6. The sync occurs hourly, so your script might need to refresh its category and file lists periodically to catch any new additions.

### Manual Sync

If you need to manually trigger a sync, you can run:

```bash
/home/[USERNAME]/sync_dropbox.sh
```

This will sync the `radioTimeMachine` folder from your Dropbox to the `/home/[USERNAME]/audio` folder on your Raspberry Pi.

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