# Multi-stage build for pyVideoTrans - with headless GUI support via Xvfb
# -------------------------------------------------
#  Builder stage – compile and install Python deps
# -------------------------------------------------
FROM python:3.10-slim-bookworm AS builder

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /build

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

RUN python -m pip install --upgrade pip setuptools wheel && \
    python -m venv /opt/venv

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"
ENV PIP_NO_CACHE_DIR=1

COPY pyproject.toml .
RUN pip install --default-timeout=300 --no-cache-dir .

# -------------------------------------------------
#  Runtime stage – with headless GUI support
# -------------------------------------------------
FROM python:3.10-slim-bookworm

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /app

COPY --from=builder /opt/venv /opt/venv

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        libsndfile1 \
        ca-certificates \
        xvfb \
        x11-utils \
        libegl1 \
        libgbm1 \
        libgl1-mesa-glx \
        libxkbcommon0 \
        libxrandr2 \
        libxinerama1 \
        libxcursor1 \
        libxcomposite1 \
        libxdamage1 \
        libatk1.0-0 \
        libatk-bridge2.0-0 && \
    rm -rf /var/lib/apt/lists/*

ENV VIRTUAL_ENV=/opt/venv
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}" \
    PYTHONPATH="/app" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    QT_QPA_PLATFORM="eglfs" \
    QT_EGL_SERVER_DEVICE=" /dev/dri/card0" \
    QT_DEBUG_PLUGINS=1

RUN groupadd -r appuser && \
    useradd -r -g appuser -d /app -s /bin/bash appuser && \
    chown -R appuser:appuser /app

USER appuser

COPY --chown=appuser:appuser . .

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh

EXPOSE 11160

ENTRYPOINT ["/entrypoint.sh"]
