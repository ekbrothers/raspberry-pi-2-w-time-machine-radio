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

# Raspberry Pi Time Machine Radio

This project implements a time-traveling radio using a Raspberry Pi Zero 2 W, allowing users to explore music from different decades using potentiometers for control.

## Table of Contents

1. [User Interactions](#user-interactions)
2. [Hardware Setup](#hardware-setup)
3. [Dropbox Sync and Folder Structure](#dropbox-sync-and-folder-structure)
4. [Software Implementation](#software-implementation)

## User Interactions

1. **Playback On/Off**:
   - Press the switch on the left potentiometer (turn to far counterclockwise position) to toggle the playback state of the radio.
   - When turned on, the radio will start playing a track from the currently selected decade or event.
   - When turned off, all playback will stop, but the Raspberry Pi remains operational.

2. **Volume Control**:
   - Rotate the left potentiometer to adjust the volume.
   - Turning clockwise increases the volume, while turning counterclockwise decreases it.
   - The high-resolution ADC allows for fine-grained volume control.

3. **Track Selection**:
   - Rotate the right potentiometer to select a track within the current decade or event.
   - Tracks are arranged in alphabetical order from left to right.
   - As you rotate the potentiometer, the radio will automatically switch to the selected track and begin playback.

4. **Decade/Event Selection**:
   - To change the decade or historical event, turn the right potentiometer to its far counterclockwise position to activate the built-in switch.
   - Each time you turn to this position and then release (turn slightly clockwise), you'll move to the next decade/event in chronological order.
   - The sequence of actions is:
     1. Turn fully counterclockwise (switch activates)
     2. Turn slightly clockwise (switch deactivates)
     3. Decade/event changes
   - After reaching the most recent decade/event, it will cycle back to the earliest one.
   - The radio will automatically start playing a track from the newly selected decade/event.
   - Note: Be careful not to turn the potentiometer too far clockwise when releasing, as this might inadvertently select a different track within the new decade/event.

5. **Continuous Playback**:
   - Once a track is playing, it will continue until you change the track, change the decade/event, or turn off playback.
   - There is no need to hold the potentiometer in position; the track will play to completion unless interrupted.

6. **Fine-Tuning**:
   - Both volume and track selection are sensitive to small movements of the potentiometers, allowing for precise control.
   - The ADS1115 ADC provides 65,536 distinct values for each potentiometer, enabling very fine adjustments.

7. **Time Travel Experience**:
   - When you change decades or events by activating the right potentiometer switch, the transition creates a "time travel" effect.
   - This effect is achieved through the immediate change in music style and era as you move between different time periods or historical events.

# Hardware Setup

## Components
- Raspberry Pi Zero 2 W
- Innomaker Raspberry Pi HiFi DAC MINI HAT (PCM5122)
- 2 rotary potentiometers with built-in switches:
  - Left potentiometer: Volume control and playback on/off
  - Right potentiometer: Track selection and decade change
- Speaker (connected to the DAC HAT)
- ADS1115 16-Bit ADC

## GPIO Connections

### 1. Left Potentiometer (Volume/Playback)

| Function | Description | Raspberry Pi Pin | GPIO Number |
|----------|-------------|------------------|-------------|
| VCC | Power supply for potentiometer | Pin 1 | 3.3V |
| GND | Ground for potentiometer | Pin 6 | GND |
| WIPER | Variable voltage output | - | Connects to ADS1115 A0 |
| SW1 | One side of the switch | Pin 13 | GPIO 27 |
| SW2 | Other side of the switch | Pin 14 | GND |

### 2. Right Potentiometer (Track/Decade)

| Function | Description | Raspberry Pi Pin | GPIO Number |
|----------|-------------|------------------|-------------|
| VCC | Power supply for potentiometer | Pin 1 | 3.3V |
| GND | Ground for potentiometer | Pin 6 | GND |
| WIPER | Variable voltage output | - | Connects to ADS1115 A1 |
| SW1 | One side of the switch | Pin 18 | GPIO 24 |
| SW2 | Other side of the switch | Pin 25 | GND |

### 3. ADS1115 ADC

| Function | Description | ADS1115 Pin | Raspberry Pi Pin | GPIO Number |
|----------|-------------|-------------|------------------|-------------|
| VDD | Power supply | VDD | Pin 1 | 3.3V |
| GND | Ground | GND | Pin 6 | GND |
| SCL | I2C Clock | SCL | Pin 5 | GPIO 3 (SCL) |
| SDA | I2C Data | SDA | Pin 3 | GPIO 2 (SDA) |
| A0 | Analog Input 0 | A0 | - | Left Potentiometer Wiper |
| A1 | Analog Input 1 | A1 | - | Right Potentiometer Wiper |
| ADDR | Address Pin | ADDR | - | Connect to GND for default address |
| ALRT | Alert | ALRT | - | Not used in this setup |

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

### 5. Speaker

Connect to the appropriate output terminals on the Innomaker DAC HAT. Refer to the DAC HAT documentation for specific terminal locations.

## Considerations and Lessons Learned

1. Debouncing is crucial for the switches to prevent unintended multiple triggers.
2. The ADS1115 provides much more precise readings than direct GPIO analog input.
3. Proper grounding and power supply connections are essential for stable ADC readings.
4. The I2C bus is shared between the DAC HAT and the ADS1115, so care must be taken to avoid address conflicts.
5. Regular logging helps in diagnosing issues and understanding the system's behavior.

## Most Recent Working Script

Here's the most recent working script for the Time Machine Radio:

```python
import RPi.GPIO as GPIO
import time
import os
import random
import logging
from typing import List, Optional
import pygame
import board
import busio
import adafruit_ads1x15.ads1115 as ADS
from adafruit_ads1x15.analog_in import AnalogIn
from contextlib import contextmanager

# Configuration
MUSIC_LIBRARY_PATH = "/home/ekbro/audio"
LOG_FILE = "/home/ekbro/time_machine_radio.log"
LEFT_SWITCH_PIN = 27
RIGHT_SWITCH_PIN = 24
DEBOUNCE_TIME = 0.3

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler()
    ]
)

class TimeMachineRadio:
    def __init__(self):
        self.current_decade: Optional[str] = None
        self.current_track: Optional[str] = None
        self.is_playing: bool = False
        self.decades: List[str] = []
        self.last_switch_time = {LEFT_SWITCH_PIN: 0, RIGHT_SWITCH_PIN: 0}

        # GPIO Setup
        GPIO.setmode(GPIO.BCM)
        GPIO.setup(LEFT_SWITCH_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)
        GPIO.setup(RIGHT_SWITCH_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)

        # ADC Setup
        i2c = busio.I2C(board.SCL, board.SDA)
        ads = ADS.ADS1115(i2c)
        self.pot_left = AnalogIn(ads, ADS.P0)
        self.pot_right = AnalogIn(ads, ADS.P1)

        # Audio setup
        pygame.mixer.init()

    def load_decades(self) -> None:
        try:
            self.decades = [d for d in os.listdir(MUSIC_LIBRARY_PATH) if os.path.isdir(os.path.join(MUSIC_LIBRARY_PATH, d))]
            self.decades.sort()
            logging.info(f"Loaded decades: {self.decades}")
        except Exception as e:
            logging.error(f"Error loading decades: {e}")
            self.decades = []

    def get_decade(self) -> Optional[str]:
        if not self.decades:
            return None
        pot_value = self.pot_right.value
        index = int(pot_value / (65536 / len(self.decades)))
        return self.decades[min(index, len(self.decades) - 1)]

    def get_track(self, decade: str) -> Optional[str]:
        tracks = [f for f in os.listdir(os.path.join(MUSIC_LIBRARY_PATH, decade)) if f.endswith('.mp3')]
        if not tracks:
            return None
        pot_value = self.pot_left.value
        index = int(pot_value / (65536 / len(tracks)))
        return tracks[min(index, len(tracks) - 1)]

    def play_track(self, decade: str, track: str) -> None:
        self.current_decade = decade
        self.current_track = track
        track_path = os.path.join(MUSIC_LIBRARY_PATH, decade, track)
        try:
            pygame.mixer.music.load(track_path)
            pygame.mixer.music.play()
            self.is_playing = True
            logging.info(f"Now playing: {track} from {decade}")
        except Exception as e:
            logging.error(f"Error playing track {track}: {e}")

    def stop_playback(self) -> None:
        pygame.mixer.music.stop()
        self.is_playing = False
        logging.info("Playback stopped")

    def debounced_switch(self, pin: int) -> bool:
        current_time = time.time()
        if current_time - self.last_switch_time[pin] > DEBOUNCE_TIME:
            self.last_switch_time[pin] = current_time
            return GPIO.input(pin) == GPIO.LOW
        return False

    @contextmanager
    def gpio_cleanup(self):
        try:
            yield
        finally:
            GPIO.cleanup()
            pygame.mixer.quit()
            logging.info("GPIO cleaned up and mixer quit")

    def run(self) -> None:
        logging.info("Time Machine Radio starting up...")
        self.load_decades()
        if not self.decades:
            logging.error("No decades found in the music library!")
            return

        with self.gpio_cleanup():
            try:
                last_decade = None
                last_track = None
                while True:
                    left_switch = self.debounced_switch(LEFT_SWITCH_PIN)
                    right_switch = self.debounced_switch(RIGHT_SWITCH_PIN)

                    if left_switch:
                        if self.is_playing:
                            self.stop_playback()
                        else:
                            decade = self.get_decade()
                            if decade:
                                track = self.get_track(decade)
                                if track:
                                    self.play_track(decade, track)
                        time.sleep(0.5)

                    if self.is_playing:
                        decade = self.get_decade()
                        if decade != last_decade:
                            track = self.get_track(decade)
                            if track:
                                self.play_track(decade, track)
                            last_decade = decade
                            last_track = track
                        else:
                            track = self.get_track(decade)
                            if track != last_track:
                                self.play_track(decade, track)
                                last_track = track

                    time.sleep(0.1)

            except KeyboardInterrupt:
                logging.info("Time Machine Radio shutting down...")
            except Exception as e:
                logging.exception(f"An unexpected error occurred: {e}")

if __name__ == "__main__":
    radio = TimeMachineRadio()
    radio.run()
```

This script incorporates the ADS1115 for precise potentiometer readings and implements debouncing for the switches. It provides a smooth experience for selecting decades and tracks using the potentiometers while maintaining the power on/off functionality with the left switch.

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