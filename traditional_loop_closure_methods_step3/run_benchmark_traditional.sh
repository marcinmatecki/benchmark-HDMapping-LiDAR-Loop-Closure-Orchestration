#!/bin/bash

set -e

usage() {
    echo "Usage:"
    echo "  $0 <kitti_dir> <output_dir>"
    echo
    echo "kitti_dir   : path to KITTI dataset"
    echo "output_dir  : directory to store KISS Matcher results"
    exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

if [[ $# -ne 2 ]]; then
    usage
fi

KITTI_DIR=$(realpath "$1")
OUTPUT_DIR=$(realpath "$2")

mkdir -p "$OUTPUT_DIR"

CLONE_DIR="$HOME/hdmapping-benchmark-loop-closure"
KISS_MATCHER_REPO="$CLONE_DIR/KISS-MATCHER-to-HDMAPPING"
KISS_MATCHER_IMAGE="kiss-matcher"

echo "==========================================="
echo "STEP 3 - TRADITIONAL LOOP CLOSURE METHODS"
echo "==========================================="

if [[ ! -d "$KITTI_DIR" ]]; then
    echo
    echo "ERROR: KITTI dataset not found:"
    echo "$KITTI_DIR"
    exit 1
fi


if [[ ! -d "$KISS_MATCHER_REPO" ]]; then
    echo
    echo "ERROR: KISS Matcher repository not found:"
    echo "$KISS_MATCHER_REPO"
    exit 1
fi

echo
echo "==========================================="
echo "RUNNING KISS MATCHER"
echo "==========================================="

KISS_MATCHER_SCRIPT="$KISS_MATCHER_REPO/docker_session_run-ros2-kiss-matcher.sh"

chmod +x "$KISS_MATCHER_SCRIPT"

"$KISS_MATCHER_SCRIPT" \
    "$KITTI_DIR" \
    "$OUTPUT_DIR"

echo
echo "==========================================="
echo "STEP 3 DONE"
echo "==========================================="

echo
echo "Results:"
echo "$OUTPUT_DIR"