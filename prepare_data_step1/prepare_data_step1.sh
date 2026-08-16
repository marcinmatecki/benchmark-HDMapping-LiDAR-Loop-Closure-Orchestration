#!/bin/bash
set -e

DATA_DIR="$HOME/hdmapping-benchmark-loop-closure/data"
KITTI_URL="https://s3.eu-central-1.amazonaws.com/avg-kitti/raw_data/2011_09_30_drive_0016/2011_09_30_drive_0016_extract.zip"
ROS2_URL="https://huggingface.co/datasets/kubchud/kitti_to_ros/resolve/main/kitti_seq04_ros2.zip"
KITTI_ZIP="$DATA_DIR/2011_09_30_drive_0016_extract.zip"
ROS2_ZIP="$DATA_DIR/kitti_seq04_ros2.zip"
KITTI_DIR="$DATA_DIR/2011_09_30"
KITTI_ROS2_DIR="$DATA_DIR/2011_09_30_drive_0016_extract_ros2"
ROS2_DIR="$DATA_DIR/2011_09_30_drive_0016_extract_ros2"
ROS1_BAG_URL="https://huggingface.co/datasets/kubchud/kitti_to_ros/resolve/main/kitti_seq04_ros1.bag"
ROS1_BAG="$DATA_DIR/kitti_seq04_ros1.bag"

mkdir -p "$DATA_DIR"
cd "$DATA_DIR"

echo "==========================================="
echo "STEP 1 - PREPARE DATA"
echo "==========================================="

echo "Data directory:"
echo "$DATA_DIR"

echo

echo "==========================================="
echo "Downloading KITTI dataset"
echo "==========================================="

if [[ -f "$KITTI_ZIP" ]]; then
    echo "KITTI archive already exists:"
    echo "$KITTI_ZIP"
else
    wget -O "$KITTI_ZIP" "$KITTI_URL"
fi

echo
echo "==========================================="
echo "Extracting KITTI dataset"
echo "==========================================="

if [[ -d "$DATA_DIR/2011_09_30_drive_0016_extract" ]]; then
    echo "KITTI dataset already extracted."
else
    unzip -q "$KITTI_ZIP" -d "$DATA_DIR"
fi

echo
echo "==========================================="
echo "Downloading KITTI ROS2 dataset"
echo "==========================================="

if [[ -f "$ROS2_ZIP" ]]; then
    echo "ROS2 archive already exists:"
    echo "$ROS2_ZIP"
else
    wget -O "$ROS2_ZIP" "$ROS2_URL"
fi

echo
echo "==========================================="
echo "Downloading KITTI ROS1 bag"
echo "==========================================="

if [[ -f "$ROS1_BAG" ]]; then
    echo "ROS1 bag already exists:"
    echo "$ROS1_BAG"
else
    wget -O "$ROS1_BAG" "$ROS1_BAG_URL"
fi

echo
echo "==========================================="
echo "Extracting KITTI ROS2 dataset"
echo "==========================================="

if [[ -d "$DATA_DIR/kitti_seq04_ros2" ]]; then
    echo "ROS2 dataset already extracted."
else
    unzip -q "$ROS2_ZIP" -d "$DATA_DIR"
fi

echo
echo "==========================================="
echo "CHECKING DATA"
echo "==========================================="

echo
echo "KITTI:"
if [[ -d "$KITTI_DIR" ]]; then
    echo "OK: $KITTI_DIR"
else
    echo "ERROR: $KITTI_DIR not found"
    exit 1
fi

echo
echo "KITTI ROS2:"
if [[ -d "$KITTI_ROS2_DIR" ]]; then
    echo "OK: $KITTI_ROS2_DIR"
else
    echo "ERROR: $KITTI_ROS2_DIR not found"
    exit 1
fi

echo
echo "ROS2:"
if [[ -d "$ROS2_DIR" ]]; then
    echo "OK: $ROS2_DIR"
else
    echo "ERROR: $ROS2_DIR not found"
    exit 1
fi

echo
echo "KITTI ROS1 BAG:"
if [[ -f "$ROS1_BAG" ]]; then
    echo "OK: $ROS1_BAG"
else
    echo "ERROR: $ROS1_BAG not found"
    exit 1
fi

echo
echo "==========================================="
echo "STEP 1 DONE"
echo "==========================================="

echo
echo "Data available in:"
echo "$DATA_DIR"