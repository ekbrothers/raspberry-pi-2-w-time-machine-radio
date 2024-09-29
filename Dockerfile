FROM python:3.9-slim-buster

   # Install system dependencies
   RUN apt-get update && apt-get install -y \
       alsa-utils \
       libasound2-dev \
       libsdl2-dev \
       && rm -rf /var/lib/apt/lists/*

   WORKDIR /app

   # Copy requirements first for better caching
   COPY requirements.txt .

   # Install Python dependencies
   RUN pip install --no-cache-dir -r requirements.txt

   # Mock RPi.GPIO for non-Raspberry Pi environments
   RUN pip install fake-rpi

   # Copy the rest of the application
   COPY . .

   # Set environment variable to use fake-rpi
   ENV GPIOZERO_PIN_FACTORY=mock

   CMD ["python", "main.py"]