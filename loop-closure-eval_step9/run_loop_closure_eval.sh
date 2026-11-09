#!/bin/bash
 
IMAGE_NAME="loop-closure-eval"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
 
DATA_DIR=~/hdmapping-benchmark-loop-closure/data
RESULTS_DIR="$DATA_DIR/tum/loop-closure-results"

cd "$SCRIPT_DIR" || exit 1
 
echo "Building Docker image '$IMAGE_NAME'..."
docker build -t "$IMAGE_NAME" . || exit 1
 
mkdir -p "$RESULTS_DIR" 

docker run --rm \
    --user 1000:1000 \
    -v ~/hdmapping-benchmark-loop-closure/data:/data \
    -w /data \
    "$IMAGE_NAME" \
    python3 /app/loop_clouds_to_edges.py || exit 1

docker run --rm --user 1000:1000 \
    -v ~/hdmapping-benchmark-loop-closure/data:/data -w /data \
    loop-closure-eval:latest \
    python3 /app/plot_gt.py tum/ground_truth.tum \
    --save tum/loop-closure-results/gt_trajectory.png --no_show

# PIN-SLAM
docker run --rm \
    --user 1000:1000 \
    -v ~/hdmapping-benchmark-loop-closure/data:/data \
    -w /data \
    "$IMAGE_NAME" \
    python3 /app/compare_loop_edges.py \
    tum/ground_truth.tum tum/pin_slam_edges.csv \
    --dist 5 --min_dt 30 \
    --t_offset_from tum/output_hdmapping-PIN-SLAM_trajectory_tum.txt \
    --name pin_slam --csv tum/loop-closure-results/metrics.csv \
    --no_show --save tum/loop-closure-results/pin_slam_result.png

# SC-F-LOAM
docker run --rm \
    --user 1000:1000 \
    -v ~/hdmapping-benchmark-loop-closure/data:/data \
    -w /data \
    "$IMAGE_NAME" \
    python3 /app/compare_loop_edges.py \
    tum/ground_truth.tum tum/sc_f_loam_edges.csv \
    --dist 5 --min_dt 30 \
    --t_offset_from tum/output_hdmapping-optimized-sc-f-loam_trajectory_tum.txt \
    --name sc_f_loam --csv tum/loop-closure-results/metrics.csv \
    --no_show --save tum/loop-closure-results/sc_f_loam_result.png