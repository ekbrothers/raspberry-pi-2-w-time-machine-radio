FROM python:3.9-slim-buster

# Install system dependencies
RUN apt-get update && apt-get install -y \
    alsa-utils \
    libasound2-dev \
    libportaudio2 \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Run the application
CMD ["python", "src/main.py"]