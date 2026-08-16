#!/bin/bash

set -e


usage() {
    echo "Usage:"
    echo "  $0 <input_bag> <output_dir>"
    echo
    echo "input_bag  : path to ROS1 bag"
    echo "output_dir : directory to store BEV-LIO-LC results"
    exit 1
}


if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi


if [[ $# -ne 2 ]]; then
    usage
fi


INPUT_BAG=$(realpath "$1")
OUTPUT_DIR=$(realpath "$2")


mkdir -p "$OUTPUT_DIR"


CLONE_DIR="$HOME/hdmapping-benchmark-loop-closure"

BEV_LIO_LC_REPO="$CLONE_DIR/BEV-LIO-LC-to-HDMAPPING"

BEV_LIO_LC_SCRIPT="$BEV_LIO_LC_REPO/docker_session_run-ros1-bev-lio-lc.sh"


echo "==========================================="
echo "STEP 4 - AI LOOP CLOSURE METHODS"
echo "==========================================="

echo
echo "Input BAG:"
echo "$INPUT_BAG"

echo
echo "Output directory:"
echo "$OUTPUT_DIR"

echo
echo "BEV-LIO-LC Docker script:"
echo "$BEV_LIO_LC_SCRIPT"


if [[ ! -f "$INPUT_BAG" ]]; then
    echo
    echo "ERROR: BAG file not found:"
    echo "$INPUT_BAG"
    exit 1
fi


if [[ ! -f "$BEV_LIO_LC_SCRIPT" ]]; then
    echo
    echo "ERROR: BEV-LIO-LC Docker script not found:"
    echo "$BEV_LIO_LC_SCRIPT"
    exit 1
fi


chmod +x "$BEV_LIO_LC_SCRIPT"


echo
echo "==========================================="
echo "RUNNING BEV-LIO-LC"
echo "==========================================="


"$BEV_LIO_LC_SCRIPT" \
    "$INPUT_BAG" \
    "$OUTPUT_DIR"


echo
echo "==========================================="
echo "STEP 4 DONE"
echo "==========================================="

