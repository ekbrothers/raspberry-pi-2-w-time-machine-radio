<!-- vscode-markdown-toc -->
* 1. [User Interactions](#UserInteractions)
* 2. [Repository Structure](#RepositoryStructure)
* 3. [Local Development](#LocalDevelopment)
* 4. [Workflows](#Workflows)
* 5. [Hardware Setup](#HardwareSetup)
* 6. [Deployment](#Deployment)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

# Raspberry Pi Time Machine Radio

This project implements a time-traveling radio using a Raspberry Pi Zero 2 W, allowing users to explore music from different decades using potentiometers for control.

##  1. <a name='UserInteractions'></a>User Interactions

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

##  2. <a name='RepositoryStructure'></a>Repository Structure

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

##  3. <a name='LocalDevelopment'></a>Local Development

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

##  4. <a name='Workflows'></a>Workflows

1. `docker-publish.yml`:
   - Triggers on push to main branch
   - Builds multi-architecture Docker image (amd64, arm/v7, arm64)
   - Pushes image to GitHub Container Registry

2. `validate-package.yml`:
   - Runs after successful `docker-publish` workflow
   - Pulls the newly built image
   - Validates image contents and installed packages
   - Ensures the container starts successfully

##  5. <a name='HardwareSetup'></a>Hardware Setup

- Raspberry Pi Zero 2 W
- InnoMaker Raspberry Pi HIFI DAC HAT PCM5122
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

The DAC HAT should be properly seated on the Raspberry Pi's GPIO pins.

##  6. <a name='Deployment'></a>Deployment

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