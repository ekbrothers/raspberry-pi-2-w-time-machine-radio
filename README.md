# Raspberry Pi Time Machine Radio

This project implements a time-traveling radio using a Raspberry Pi Zero 2 W, allowing users to explore music from different decades using potentiometers for control.

## Table of Contents

- [User Interactions](#user-interactions)
- [Repository Structure](#repository-structure)
- [Local Development](#local-development)
- [Workflows](#workflows)
- [Hardware Setup](#hardware-setup)
- [Setting up the BossDAC](#setting-up-the-bossdac)
- [Deployment](#deployment)

## User Interactions

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

## Repository Structure

```
raspberry-pi-2-w-time-machine-radio/
│
├── .github/workflows/
│   ├── docker-publish.yml
│   └── validate-package.yml
│
├── src/
│   └── main.py
│
├── Dockerfile
├── requirements.txt
└── README.md
```

- `src/main.py`: Core application logic
- `Dockerfile`: Defines the container for both development and production
- `requirements.txt`: Lists Python dependencies

## Local Development

1. Clone the repository:
   ```
   git clone https://github.com/ekbrothers/raspberry-pi-2-w-time-machine-radio.git
   cd raspberry-pi-2-w-time-machine-radio
   ```

2. Build the Docker image:
   ```
   docker build -t time-machine-radio .
   ```

3. Run the container:
   ```
   docker run -it --rm time-machine-radio
   ```

This setup allows for development on non-Raspberry Pi systems by mocking GPIO functionality.

## Workflows

1. `docker-publish.yml`:
   - Triggers on push to main branch
   - Builds multi-architecture Docker image (amd64, arm/v7, arm64)
   - Pushes image to GitHub Container Registry

2. `validate-package.yml`:
   - Runs after successful `docker-publish` workflow
   - Pulls the newly built image
   - Validates image contents and installed packages
   - Ensures the container starts successfully

## Hardware Setup

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

The BossDAC should be properly seated on the Raspberry Pi's GPIO pins.

## Setting up the BossDAC

### 1. Configure Raspberry Pi

Edit the boot configuration file:

```bash
sudo nano /boot/firmware/config.txt
```

Add the following lines at the end of the file:

```
dtoverlay=allo-boss-dac-pcm512x-audio
dtparam=i2s=on
```

If you see `dtparam=audio=on`, comment it out by adding a `#` at the beginning of the line:

```
#dtparam=audio=on
```

Save and exit the editor (Ctrl+X, then Y, then Enter).

### 2. Reboot Raspberry Pi

```bash
sudo reboot
```

### 3. Verify DAC Recognition

After rebooting, check if the BossDAC is recognized:

```bash
aplay -l
```

You should see output similar to:

```
card 1: BossDAC [BossDAC], device 0: Boss DAC HiFi [Master] pcm512x-hifi-0 [Boss DAC HiFi [Master] pcm512x-hifi-0]
```

Verify that the driver is loaded:

```bash
lsmod | grep snd_soc_allo_boss_dac
```

You should see `snd_soc_allo_boss_dac` in the output.

### 4. Create a Test Sound

Install the `sox` tool if not already present:

```bash
sudo apt-get update
sudo apt-get install sox
```

Create a 5-second test tone:

```bash
sox -n -r 44100 -c 2 test_tone.wav synth 5 sine 1000
```

### 5. Test the DAC

Play the test tone through the BossDAC:

```bash
aplay -D plughw:1,0 test_tone.wav
```

Or, if you've set the BossDAC as the default audio device:

```bash
aplay test_tone.wav
```

You should hear a 5-second beep through your speakers or headphones connected to the BossDAC.

### Troubleshooting

If you encounter issues:

1. Ensure the BossDAC is properly seated on the Raspberry Pi's GPIO pins.
2. Check that you're using a power supply capable of providing at least 3A.
3. Verify I2C detection:

   ```bash
   sudo i2cdetect -y 1
   ```

   You should see a device detected (usually at address 0x4d).

4. Check system logs for any error messages:

   ```bash
   dmesg | grep -i boss
   ```

If problems persist, consult the BossDAC documentation or contact their support for further assistance.

## Deployment

To deploy on your Raspberry Pi:

1. Pull the latest image:
   ```
   docker pull ghcr.io/ekbrothers/raspberry-pi-2-w-time-machine-radio:latest
   ```

2. Run the container:
   ```
   docker run --device /dev/snd:/dev/snd -v /home/pi/audio:/app/audio ghcr.io/ekbrothers/raspberry-pi-2-w-time-machine-radio:latest
   ```

Ensure your audio files are organized in `/home/pi/audio` with subdirectories for each decade.
