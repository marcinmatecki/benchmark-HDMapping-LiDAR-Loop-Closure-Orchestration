#!/bin/bash

usage() {
  echo "Usage:"
  echo "  $0 <ros1_bag> <output_dir>"
  echo
  echo "ros1_bag      : path to a ROS1 .bag file"
  echo "output_dir    : directory to store outputs"
  exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

if [[ $# -ne 2 ]]; then
    usage
fi

ROS1_BAG=$(realpath "$1")
OUTPUT_DIR=$(realpath "$2")

mkdir -p "$OUTPUT_DIR"

CLONE_DIR="$HOME/hdmapping-benchmark-loop-closure"

mkdir -p $CLONE_DIR/benchmark-Optimized-SC-F-LOAM-to-HDMapping/message/Scans

ROS1_REPOS=(
"benchmark-Optimized-SC-F-LOAM-to-HDMapping"
)

ROS1_ALGOS=(
  "optimized-sc-f-loam"
)

for i in "${!ROS1_ALGOS[@]}"; do
    algo="${ROS1_ALGOS[$i]}"
    repo="${ROS1_REPOS[$i]}"
    OUTPUT="$OUTPUT_DIR/$algo"
    mkdir -p "$OUTPUT"

    INPUT="$ROS1_BAG"

    echo "=== Waiting 5 seconds before running $algo ==="
    sleep 5

    cd "$CLONE_DIR/$repo"
    echo "=== Running $algo in $(pwd) on $INPUT ==="
    ./docker_session_run-ros1-"$algo".sh "$INPUT" "$OUTPUT"

    cd "$CLONE_DIR"
    echo "=== Finished $algo ==="
done

ROS_REPOS=(
"benchmark-PIN-SLAM-to-HDMapping"
)

ROS_ALGOS=(
  "pin-slam"
)

for i in "${!ROS_ALGOS[@]}"; do
    algo="${ROS_ALGOS[$i]}"
    repo="${ROS_REPOS[$i]}"
    OUTPUT="$OUTPUT_DIR/$algo"
    mkdir -p "$OUTPUT"
    mkdir -p "$OUTPUT/pin_experiments"

    INPUT="$ROS1_BAG"

    echo "=== Waiting 5 seconds before running $algo ==="
    sleep 5

    cd "$CLONE_DIR/$repo"
    echo "=== Running $algo in $(pwd) on $INPUT ==="
    ./docker_session_run-"$algo".sh "$INPUT" "$OUTPUT"

    cd "$CLONE_DIR"
    echo "=== Finished $algo ==="
done
