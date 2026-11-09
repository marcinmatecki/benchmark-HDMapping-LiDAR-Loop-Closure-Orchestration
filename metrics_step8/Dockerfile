FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-venv \
        ca-certificates \
        libegl1 \
        libgl1 \
        libgomp1 \
        libx11-6 \
        libusb-1.0-0 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PYTHON_DOWNLOADS=never \
    UV_PYTHON=python3.12

COPY point_clouds_evaluation /app/point_clouds_evaluation

WORKDIR /app/point_clouds_evaluation

RUN rm -rf .venv && uv sync --frozen

ENV PATH="/app/point_clouds_evaluation/.venv/bin:$PATH"

COPY metrics_tables.py /app/metrics_tables.py