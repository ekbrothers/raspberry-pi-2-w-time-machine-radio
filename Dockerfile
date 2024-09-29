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

# Install RPi.GPIO only on ARM architectures
RUN if [ "$(uname -m)" = "armv7l" ] || [ "$(uname -m)" = "aarch64" ]; then \
        pip install RPi.GPIO; \
    else \
        pip install fake-rpi; \
    fi

# Copy the rest of the application
COPY . .

# Set environment variable to use fake-rpi on non-ARM architectures
ENV GPIOZERO_PIN_FACTORY=mock

CMD ["python", "src/main.py"]