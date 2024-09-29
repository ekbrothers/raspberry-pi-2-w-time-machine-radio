FROM python:3.9-slim-buster

# Install system dependencies and build tools
RUN apt-get update && apt-get install -y \
    gcc \
    libasound2-dev \
    libsdl2-dev \
    libsdl2-mixer-2.0-0 \
    libsdl2-image-2.0-0 \
    libsdl2-ttf-2.0-0 \
    libfreetype6-dev \
    libportmidi-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Upgrade pip
RUN pip install --upgrade pip

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install gpiozero only on ARM architectures
RUN if [ "$(uname -m)" = "armv7l" ] || [ "$(uname -m)" = "aarch64" ]; then \
        pip install gpiozero; \
    else \
        pip install fake-rpi; \
    fi

# Copy the rest of the application
COPY . .

# Set environment variable to use fake-rpi on non-ARM architectures
ENV GPIOZERO_PIN_FACTORY=mock

CMD ["python", "src/main.py"]