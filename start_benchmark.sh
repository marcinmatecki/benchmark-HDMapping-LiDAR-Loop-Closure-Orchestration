#!/bin/bash

set -e

DATA_DIR=~/hdmapping-benchmark-loop-closure/data
REPO_DIR=~/hdmapping-benchmark-loop-closure/benchmark-HDMapping-LiDAR-LoopClosure-Orchestration
mkdir -p "$DATA_DIR"
cd "$DATA_DIR"

echo "=== Step 1: prepare_data_step1 ==="

# ROS1_BAG="$DATA_DIR/kitti_${SEQ}_ros1.bag"

# if [ -f "$ROS1_BAG" ]; then

#     echo "Step 1 outputs for $SEQ exist. Skipping."

# else

#     echo "Step 1 incomplete for $SEQ. Missing:"

#     if [ ! -f "$ROS1_BAG" ]; then
#         echo " - $ROS1_BAG"
#     fi

#     echo "Removing old partial outputs..."

#     rm -rf \
#         "$ROS1_BAG" \
#         "$ROS2_DIR" \
#         "$ROS2_LIDAR_DIR"

#     echo "Starting Step 1 conversion for $SEQ..."

#     cd "$REPO_DIR/prepare_data_step1" || exit 1
#     chmod +x *.sh

#     ./download_data.sh seq05

# fi

# sleep 5

# echo "=== Step 2: clone_github_repositories_step2 ==="
# cd "$REPO_DIR/clone_github_repositories_step2"
# chmod +x *.sh
# ./clone_github_repositories_step2.sh kitti

# sleep 5

# echo "=== Step 3: run_benchmark_step3 ==="
# cd "$REPO_DIR/run_benchmark_step3"
# chmod +x *.sh
# ./run_benchmark_step3.sh \
#     "$DATA_DIR/kitti_seq05_ros1.bag" \
#     "$DATA_DIR"

# echo "=== DONE ==="

# sleep 5

# echo "=== Step 4: conversion_tum_step4 ==="
# cd "$REPO_DIR/conversion_tum_step4"
# chmod +x *.sh
# ./run_tum_step4.sh

sleep 5

echo "=== Step 5: evo_step5 ==="
cd "$REPO_DIR/evo_step5"
chmod +x *.sh
./tum-to-latex_step5.sh

sleep 5

echo "=== Step 6: overlap_step6 ==="
cd "$REPO_DIR/overlap_step6"

if command -v python3 >/dev/null 2>&1; then
    python3 overlap.py
elif command -v python >/dev/null 2>&1; then
    python overlap.py
else
    echo "ERROR: Neither python3 nor python found"
    exit 1
fi

# sleep 5
# echo "=== Step 7: pcd-to-ply_step7 ==="
# cd "$REPO_DIR/pcd-to-ply_step7"
# chmod +x *.sh
# ./converter-pcd-to-ply-step7.sh

# sleep 5
# echo "=== Step 8: metrics_step8 ==="
# cd "$REPO_DIR/metrics_step8"
# chmod +x *.sh
# ./metrics-step8.sh


sleep 5
echo "=== Step 9: loop-closure-eval_step9 ==="
cd "$REPO_DIR/loop-closure-eval_step9"
ls "$REPO_DIR/loop-closure-eval_step9"
chmod +x *.sh
./run_loop_closure_eval.sh
