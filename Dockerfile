FROM python:3.9-slim-buster

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libsdl2-mixer-2.0-0 \
    libsdl2-2.0-0 \
    python3-pip \
    python3-setuptools \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY src/ .

# Create a directory for audio files
RUN mkdir -p /app/audio

# Run the application
CMD ["python3", "main.py"]