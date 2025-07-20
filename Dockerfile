FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY hackathon-recommender.py .

# Expose Flask port
EXPOSE 8501

# Health check
HEALTHCHECK CMD curl --fail http://localhost:8501/health || exit 1

# Run Flask app
CMD ["python", "hackathon-recommender.py"]
