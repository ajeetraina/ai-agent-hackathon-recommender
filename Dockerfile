FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the agent code
COPY coding-agent.py .

# Create output directory
RUN mkdir -p /app/output

# Run the coding agent
CMD ["python", "coding-agent.py"]
