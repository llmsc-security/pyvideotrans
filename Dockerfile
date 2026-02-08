# Multi-stage build for pyVideoTrans
# -------------------------------------------------
#  Builder stage – compile and install Python deps
# -------------------------------------------------
FROM python:3.10-slim-bookworm AS builder

# Prevent interactive prompts during apt operations
ARG DEBIAN_FRONTEND=noninteractive

# Working directory for the build
WORKDIR /build

# Install build-time system packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        pkg-config \
        ca-certificates \
        libssl-dev \
        libffi-dev \
        ffmpeg \
        libsndfile1-dev && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip/setuptools/wheel and create a virtual-env
RUN python -m pip install --upgrade pip setuptools wheel && \
    python -m venv /opt/venv

# Make the venv the default Python environment for the rest of the stage
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"
ENV PIP_NO_CACHE_DIR=1

# Install runtime Python packages
COPY pyproject.toml .
RUN pip install --default-timeout=300 --no-cache-dir .

# -------------------------------------------------
#  Runtime stage – lightweight image with app code
# -------------------------------------------------
FROM python:3.10-slim-bookworm

ARG DEBIAN_FRONTEND=noninteractive

# Application work directory
WORKDIR /app

# Copy the pre-built virtual environment from the builder
COPY --from=builder /opt/venv /opt/venv

# Install only the runtime system packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        libsndfile1 \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Environment variables
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}" \
    PYTHONPATH="/app" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Create non-root user
RUN groupadd -r appuser && \
    useradd -r -g appuser -d /app -s /bin/bash appuser && \
    chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Copy application code
COPY --chown=appuser:appuser . .

# Default command - can be overridden
CMD ["python", "sp.py"]
