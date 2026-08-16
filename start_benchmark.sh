#!/bin/bash
set -e

echo "==========================================="
echo "HDMapping LOOP CLOSURE BENCHMARK"
echo "==========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CLONE_DIR="$HOME/hdmapping-benchmark-loop-closure"
DATA_DIR="$CLONE_DIR/data"

KITTI_DIR="$DATA_DIR/2011_09_30/2011_09_30_drive_0016_extract/velodyne_points/data"
KITTI_ROS2_DIR="$DATA_DIR/2011_09_30_drive_0016_extract_ros2"
ROS2_DIR="$DATA_DIR/2011_09_30_drive_0016_extract_ros2"
ROS1_BAG="$DATA_DIR/kitti_seq04_ros1.bag"


OUTPUT_DIR="$DATA_DIR"

TRADITIONAL_OUTPUT="$DATA_DIR"
AI_OUTPUT="$DATA_DIR"
OPEN3D_OUTPUT="$DATA_DIR"

echo
echo "==========================================="
echo "STEP 1 - PREPARE DATA"
echo "==========================================="

"$SCRIPT_DIR/prepare_data_step1/prepare_data_step1.sh"

echo
echo "STEP 1 DONE"

echo
echo "==========================================="
echo "CHECKING PREPARED DATA"
echo "==========================================="

echo
echo "Data directory:"
echo "$DATA_DIR"

if [[ ! -d "$DATA_DIR" ]]; then
    echo "ERROR: Data directory does not exist:"
    echo "$DATA_DIR"
    exit 1
fi

echo "OK"

echo
echo "KITTI:"
echo "$KITTI_DIR"

if [[ ! -d "$KITTI_DIR" ]]; then
    echo "ERROR: KITTI directory does not exist:"
    echo "$KITTI_DIR"
    exit 1
fi

echo "OK"

echo
echo "KITTI ROS2:"
echo "$KITTI_ROS2_DIR"

if [[ ! -d "$KITTI_ROS2_DIR" ]]; then
    echo "ERROR: KITTI ROS2 directory does not exist:"
    echo "$KITTI_ROS2_DIR"
    exit 1
fi

echo "OK"

echo
echo "ROS2:"
echo "$ROS2_DIR"

if [[ ! -d "$ROS2_DIR" ]]; then
    echo "ERROR: ROS2 directory does not exist:"
    echo "$ROS2_DIR"
    exit 1
fi

echo "OK"

echo
echo "ROS1 BAG:"
echo "$ROS1_BAG"

if [[ ! -f "$ROS1_BAG" ]]; then
    echo "ERROR: ROS1 bag does not exist:"
    echo "$ROS1_BAG"
    exit 1
fi

echo "OK"


echo
echo "==========================================="
echo "STEP 2 - CLONE GITHUB REPOSITORIES"
echo "==========================================="

"$SCRIPT_DIR/clone_github_repositories_step2/clone_github_repositories_step2.sh" main

echo
echo "STEP 2 DONE"


echo
echo "==========================================="
echo "STEP 3 - TRADITIONAL LOOP CLOSURE"
echo "==========================================="

echo
echo "KITTI directory:"
echo "$ROS2_DIR"

echo
echo "Output directory:"
echo "$TRADITIONAL_OUTPUT"

"$SCRIPT_DIR/traditional_loop_closure_methods_step3/run_benchmark_traditional.sh" \
    "$ROS2_DIR" \
    "$TRADITIONAL_OUTPUT"

echo
echo "STEP 3 DONE"

echo
echo "==========================================="
echo "STEP 4 - AI LOOP CLOSURE"
echo "==========================================="

echo
echo "ROS1 BAG:"
echo "$ROS1_BAG"

echo
echo "Output directory:"
echo "$AI_OUTPUT"

"$SCRIPT_DIR/ai_loop_closure_methods_step4/run_benchmark_AI.sh" \
    "$ROS1_BAG" \
    "$AI_OUTPUT"

echo
echo "STEP 4 DONE"


echo
echo "==========================================="
echo "STEP 5 - OPEN3D"
echo "==========================================="

echo
echo "KITTI directory:"
echo "$KITTI_DIR"

echo
echo "Output directory:"
echo "$OPEN3D_OUTPUT"

"$SCRIPT_DIR/open3d_loop_closure_step5/run_benchmark_Open3D.sh" \
    "$KITTI_DIR" \
    "$OPEN3D_OUTPUT"

echo
echo "STEP 5 DONE"


echo
echo "==========================================="
echo "BENCHMARK FINISHED"
echo "==========================================="

echo
echo "Data directory:"
echo "$DATA_DIR"

echo
echo "All benchmark results are stored in:"
echo "$OUTPUT_DIR"

echo
echo "==========================================="