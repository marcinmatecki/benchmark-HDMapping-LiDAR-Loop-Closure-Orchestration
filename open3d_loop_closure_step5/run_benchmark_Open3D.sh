#!/bin/bash

set -e

CLONE_DIR="$HOME/hdmapping-benchmark-loop-closure"

OPEN3D_REPO="$CLONE_DIR/Open3D-to-HDMAPPING"

OPEN3D_SCRIPT="$OPEN3D_REPO/docker_session_run-open3d.sh"

KITTI_DIR="$1"

echo "==========================================="
echo "STEP 5 - OPEN3D "
echo "==========================================="

echo
echo "Open3D repository:"
echo "$OPEN3D_REPO"

echo
echo "KITTI directory:"
echo "$KITTI_DIR"

if [[ -z "$KITTI_DIR" ]]; then
    echo
    echo "ERROR: KITTI directory not provided."
    echo "Usage: $0 <KITTI_DIRECTORY>"
    exit 1
fi

if [[ ! -d "$KITTI_DIR" ]]; then
    echo
    echo "ERROR: KITTI directory not found:"
    echo "$KITTI_DIR"
    exit 1
fi

if [[ ! -d "$OPEN3D_REPO" ]]; then
    echo
    echo "ERROR: Open3D repository not found:"
    echo "$OPEN3D_REPO"
    exit 1
fi

if [[ ! -f "$OPEN3D_SCRIPT" ]]; then
    echo
    echo "ERROR: Open3D Docker script not found:"
    echo "$OPEN3D_SCRIPT"
    exit 1
fi

echo
echo "==========================================="
echo "RUNNING OPEN3D"
echo "==========================================="

chmod +x "$OPEN3D_SCRIPT"

"$OPEN3D_SCRIPT" "$KITTI_DIR"

echo
echo "==========================================="
echo "STEP 5 DONE"
echo "==========================================="