# 1. Use a stable Python version
FROM python:3.12-slim

# 2. Prevent Python from buffering logs (crucial for seeing errors in Cloud Run)
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# 3. Set the working directory to /app
WORKDIR /app

# 4. Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 5. Install Python dependencies (Cached layer)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 6. Copy your code. 
# This copies the 'app' folder from your computer into /app/app inside the container
COPY app/ ./app/

# 7. Security: Run as non-root user
RUN useradd --create-home --shell /bin/bash appuser && \
    chown -R appuser:appuser /app
USER appuser

# 8. Set PYTHONPATH so 'uvicorn' can find the 'app' module
ENV PYTHONPATH=/app

# 9. The Start Command
# Using 'sh -c' allows Docker to use the $PORT variable provided by Google
CMD sh -c "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8080}"