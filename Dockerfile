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

   # Copy requirements file
   COPY requirements.txt .

   # Upgrade pip and install Python dependencies
   RUN pip3 install --upgrade pip && \
       pip3 install --no-cache-dir -r requirements.txt

   # Copy the Python script
   COPY main.py .

   # Run the application
   CMD ["python3", "main.py"]