FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        libusb-1.0-0 \
        libegl1 \
        libgl1 \
        libgomp1 \
        libx11-6 && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install --break-system-packages open3d

WORKDIR /app

COPY converter-pcd-to-ply.py .