FROM python:3.9-slim-buster

WORKDIR /app

# Copy your application directory into the container
COPY website_logs-stdout.py .
COPY requirements.txt .

# Install any necessary dependencies from a requirements.txt file if you have one.
RUN pip install --no-cache-dir -r requirements.txt

# Set the command to run your Python script
CMD ["ddtrace-run", "python", "website_logs-stdout.py"]
