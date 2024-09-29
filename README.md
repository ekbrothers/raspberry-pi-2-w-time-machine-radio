# Raspberry Pi Time Machine Radio

This project implements a time-traveling radio using a Raspberry Pi Zero 2 W, allowing users to explore music from different decades using potentiometers for control.

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