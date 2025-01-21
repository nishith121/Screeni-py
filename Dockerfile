# Project             :   Screenipy
# Author              :   Pranjal Joshi
# Created             :   17/08/2023
# Description         :   Dockerfile to build Screeni-py image for GUI release

# Use a slim Python image
FROM python:3.11.6-slim-bookworm as base

ARG DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies
RUN apt-get update && apt-get install -y software-properties-common \
    && apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    vim nano wget curl \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set locale and environment variables
ENV LANG C.UTF-8
ENV PYTHONUNBUFFERED=TRUE
ENV PYTHONDONTWRITEBYTECODE=TRUE

# Add application files
ADD . /opt/program/
WORKDIR /opt/program

# Make scripts executable
RUN chmod +x *

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Install Python dependencies
RUN pip3 install -r "requirements.txt"
RUN pip3 install --no-deps advanced-ta

# Environment variables for Screenipy
ENV SCREENIPY_DOCKER=TRUE
ENV SCREENIPY_GUI=TRUE

# Add the Zscaler certificate and update CA certificates
ADD /usr/local/share/ca-certificates/zscaler.crt /usr/local/share/ca-certificates/zscaler.crt
RUN update-ca-certificates

# Expose necessary ports
EXPOSE 8000
EXPOSE 8501

# Healthcheck for the app
HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health || exit 1

# Set working directory for the application
WORKDIR /opt/program/src/

# Command to run the application
ENTRYPOINT ["streamlit", "run", "streamlit_app.py", "--server.port=8501", "--server.address=0.0.0.0"]
