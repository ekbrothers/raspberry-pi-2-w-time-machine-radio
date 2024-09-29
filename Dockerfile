FROM python:3.9-slim-buster

# Install system dependencies including SDL2 development libraries
RUN apt-get update && apt-get install -y \
    libsdl2-mixer-2.0-0 \
    libsdl2-2.0-0 \
    libsdl2-dev \                 # SDL2 development library
    libsdl2-image-2.0-0 \         # SDL image library (optional if needed)
    libsdl2-ttf-2.0-0 \           # SDL TTF font library (optional if needed)
    build-essential \             # Required for compiling some Python libraries
    python3-pip \
    python3-setuptools \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements file
COPY requirements.txt .

# Upgrade pip and install Python dependencies
RUN pip3 install --upgrade pip && \
    pip3 install --no-cache-dir -r requirements.txt

# Copy the Python script
COPY main.py .

# Run the application
CMD ["python3", "main.py"]
