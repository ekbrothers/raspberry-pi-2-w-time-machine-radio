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

##  3. <a name='RepositoryStructure'></a>Repository Structure

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

##  4. <a name='LocalDevelopment'></a>Local Development

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

##  5. <a name='Workflows'></a>Workflows

1. `docker-publish.yml`:
   - Triggers on push to main branch
   - Builds multi-architecture Docker image (amd64, arm/v7, arm64)
   - Pushes image to GitHub Container Registry

2. `validate-package.yml`:
   - Runs after successful `docker-publish` workflow
   - Pulls the newly built image
   - Validates image contents and installed packages
   - Ensures the container starts successfully

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

The BossDAC should be properly seated on the Raspberry Pi's GPIO pins.


# Docker Setup on Raspberry Pi

To set up Docker and run the Time Machine Radio on your Raspberry Pi, follow these steps:

1. Update your Raspberry Pi:
   ```
   sudo apt update
   sudo apt upgrade -y
   ```

2. Install Docker dependencies:
   ```
   sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
   ```

3. Add Docker's official GPG key:
   ```
   curl -fsSL https://download.docker.com/linux/raspbian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   ```

4. Set up the Docker repository:
   ```
   echo "deb [arch=armhf signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/raspbian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```

5. Install Docker:
   ```
   sudo apt update
   sudo apt install -y docker-ce docker-ce-cli containerd.io
   ```

6. Add your user to the Docker group (log out and back in after this step):
   ```
   sudo usermod -aG docker $USER
   ```

7. Verify Docker installation:
   ```
   docker --version
   ```

8. Authenticate with GitHub Container Registry:
   - Create a Personal Access Token (PAT) on GitHub with the appropriate permissions (read:packages).
   - Log in to ghcr.io using your GitHub username and PAT:
     ```
     echo YOUR_PAT | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
     ```
   Replace YOUR_PAT with your actual Personal Access Token and YOUR_GITHUB_USERNAME with your GitHub username.

9. Pull the latest Time Machine Radio image:
   ```
   docker pull ghcr.io/ekbrothers/raspberry-pi-2-w-time-machine-radio:latest
   ```

10. Run the Time Machine Radio container:
    ```
    docker run --device /dev/snd:/dev/snd -v /home/pi/audio:/app/audio ghcr.io/ekbrothers/raspberry-pi-2-w-time-machine-radio:latest
    ```

Make sure your audio files are organized in `/home/pi/audio` with subdirectories for each decade before running the container.

Note: Keep your Personal Access Token secure and never share it publicly. If you're distributing this project to others, you may want to consider making the container registry public or providing separate instructions for requesting access.

##  7. <a name='Deployment'></a>Deployment

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

##  8. <a name='SpecifyingtheCorrectAudioDeviceinPython'></a>Specifying the Correct Audio Device in Python

When working with the BossDAC or any specific audio device on your Raspberry Pi, it's crucial to specify the correct device in your Python script. Here's how to do it:

1. **Identify Available Devices**: 
   Use the following Python script to list all available audio devices:

   ```python
   import sounddevice as sd

   print("Available audio devices:")
   print(sd.query_devices())
   ```

2. **Specify the Device**:
   Once you've identified your DAC (usually listed as "BossDAC" or similar), you can specify it in your script using its index or name:

   ```python
   import sounddevice as sd
   import numpy as np

   # Specify the audio device to use (replace 0 with the correct index if different)
   device = 0  # or use the name, e.g., device = "BossDAC"

   # Your audio data and sample rate
   data = ...  # Your audio data
   samplerate = 44100  # or whatever is appropriate for your audio

   # Play audio
   sd.play(data, samplerate, device=device)
   sd.wait()
   ```

3. **Handle Device Selection Errors**:
   It's good practice to handle potential errors when selecting the device:

   ```python
   try:
       sd.play(data, samplerate, device=device)
       sd.wait()
   except sd.PortAudioError as e:
       print(f"Error playing audio: {e}")
       print("Available devices:")
       print(sd.query_devices())
   ```

4. **Using with Other Libraries**:
   If you're using libraries like `pygame` for audio, you may need to set the audio device before initializing:

   ```python
   import os
   os.environ['SDL_AUDIODRIVER'] = 'alsa'
   os.environ['AUDIODEV'] = 'plughw:1,0'  # Replace with your device identifier if different

   import pygame
   pygame.mixer.init()
   ```

Remember to install the necessary Python libraries (`sounddevice`, `numpy`) in your project's virtual environment:

```bash
pip install sounddevice numpy
```
##  9. <a name='DevelopmentandTestingStages'></a>Development and Testing Stages

When developing the Time Machine Radio project, it's important to balance speed of development with the robustness of your testing environment. Here's a recommended approach that progresses from rapid local development to full containerization:

###  9.1. <a name='LocalPythonDevelopmentonRaspberryPi'></a>1. Local Python Development on Raspberry Pi

**Fastest for initial development and debugging**

- Develop and test Python scripts directly on the Raspberry Pi.
- Use a virtual environment to manage dependencies.
- Pros:
  - Immediate feedback
  - Direct access to hardware (GPIO, DAC)
  - Easiest to debug hardware interactions
- Cons:
  - Less portable
  - Potential for environment inconsistencies

Example workflow:
```bash
cd ~/time_machine_radio
source venv/bin/activate
python your_script.py
```

###  9.2. <a name='LocalContainerBuildonRaspberryPi'></a>2. Local Container Build on Raspberry Pi

**Good balance of speed and environment consistency**

- Build Docker container on the Raspberry Pi itself.
- Test the containerized application locally.
- Pros:
  - Faster than pulling from remote registry
  - Tests containerization without network dependency
  - Closer to production environment
- Cons:
  - Slower than direct Python development
  - May not catch architecture-specific issues

Example workflow:
```bash
docker build -t time-machine-radio .
docker run --device /dev/snd:/dev/snd -v /home/pi/audio:/app/audio time-machine-radio
```

###  9.3. <a name='FullCICDPipelinewithRemoteContainerRegistry'></a>3. Full CI/CD Pipeline with Remote Container Registry

**Best for final testing and deployment**

- Push changes to GitHub repository.
- Allow CI/CD pipeline to build and push container to GitHub Container Registry.
- Pull and run the container on Raspberry Pi.
- Pros:
  - Full test of entire workflow
  - Ensures consistency across different devices
  - Mimics the final deployment process
- Cons:
  - Slowest development cycle
  - Requires network connectivity

Example workflow:
```bash
# After pushing changes to GitHub and CI/CD completes
docker pull ghcr.io/ekbrothers/raspberry-pi-2-w-time-machine-radio:latest
docker run --device /dev/snd:/dev/snd -v /home/pi/audio:/app/audio ghcr.io/ekbrothers/raspberry-pi-2-w-time-machine-radio:latest
```



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

###  9.5. <a name='ManagingDependencies'></a>Managing Dependencies

- **Freeze requirements**: After installing all necessary packages, create or update your `requirements.txt`:
  ```bash
  pip freeze > requirements.txt
  ```

- **Install from requirements**: To recreate the environment on another machine or after a fresh clone:
  ```bash
  pip install -r requirements.txt
  ```

###  9.6. <a name='BestPractices'></a>Best Practices

- Always activate your virtual environment before working on your project.
- Keep your `requirements.txt` file up to date.
- Don't version control your `venv` directory; add it to your `.gitignore` file.
- If you're using an IDE like PyCharm or VS Code, configure it to use your virtual environment.

###  9.7. <a name='Troubleshooting'></a>Troubleshooting

- If you encounter permissions issues, ensure you're not using `sudo` with pip inside a virtual environment.
- If you're having trouble with audio or GPIO libraries, make sure they're compiled for your specific Raspberry Pi architecture.

