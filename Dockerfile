FROM python:3.11.13-slim-bookworm

# Prevent Python from writing .pyc files
ENV PYTHONDONTWRITEBYTECODE=1
# Flush logs immediately
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install curl for healthcheck, and patch OS-level vulnerabilities
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# Copy dependency file
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application
COPY app/ .

# Create non-root user
RUN useradd --create-home appuser && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
CMD curl -f http://localhost:8000/health || exit 1

CMD ["uvicorn","main:app","--host","0.0.0.0","--port","8000"]