# Use a small, official Python image that matches the supported dependency range.
FROM python:3.12-slim
 
# Make Python logs appear immediately and avoid writing .pyc files in the image.
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    STREAMLIT_SERVER_HEADLESS=true \
    STREAMLIT_BROWSER_GATHER_USAGE_STATS=false
 
# Keep all application files in one predictable directory.
WORKDIR /app
 
# curl is used by the health check; libgomp1 is required by FAISS on Debian.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        libgomp1 \
    && rm -rf /var/lib/apt/lists/*
 
# Install dependencies in a separate layer so Docker can cache them.
COPY requirements.txt ./requirements.txt
 
RUN python -m pip install --upgrade pip \
    && python -m pip install --no-cache-dir -r requirements.txt
 
# Run the application as an unprivileged user instead of root.
RUN useradd --create-home --shell /usr/sbin/nologin appuser
 
# Copy only runtime files. Secrets are intentionally not copied.
COPY --chown=appuser:appuser app.py ./app.py
COPY --chown=appuser:appuser data ./data
 
USER appuser
 
# Streamlit listens on this port inside the container.
EXPOSE 8501
 
# Verify that Streamlit is responsive. The longer start period allows the
# embedding model to download and initialize on the first run.
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD curl --fail http://localhost:8501/_stcore/health || exit 1
 
# Bind to all container interfaces so Docker and an AWS ALB can reach the app.
ENTRYPOINT ["streamlit", "run", "app.py", "--server.address=0.0.0.0", "--server.port=8501", "--server.headless=true"]
