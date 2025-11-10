# Base devcontainer (Ubuntu 22.04)
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:bartbes/love-stable

RUN apt-get update && apt-get install -y \
    love xvfb x11vnc fluxbox novnc websockify supervisor xauth x11-apps \
    lua5.4 git curl wget unzip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js, npm, and npx
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm

# noVNC lives in /usr/share/novnc; websockify is installed system-wide
# Supervisor will manage processes
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Python + requirements (copy early for cache)
COPY requirements.txt /tmp/requirements.txt

RUN apt-get update && apt-get install -y python3 python3-pip && \
    pip3 install --no-cache-dir -r /tmp/requirements.txt && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspaces
