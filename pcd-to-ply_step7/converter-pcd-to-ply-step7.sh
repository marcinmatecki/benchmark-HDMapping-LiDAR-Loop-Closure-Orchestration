#!/bin/bash

IMAGE_NAME="pcd-to-ply"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$SCRIPT_DIR" || exit 1

echo "Building Docker image '$IMAGE_NAME'..."
docker build -t "$IMAGE_NAME" . || exit 1

docker run --rm \
    --user 1000:1000 \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/hdmapping-benchmark-loop-closure/data:/data \
    -w /data \
    "$IMAGE_NAME" \
    python3 /app/converter-pcd-to-ply.py