#!/bin/bash

IMAGE_NAME="pointcloud-metrics"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

DATA_ROOT="$HOME/hdmapping-benchmark-loop-closure/data"
OUT_DIR="$DATA_ROOT/tum"
THRESHOLD=0.05

cd "$SCRIPT_DIR" || exit 1

echo "=== Step 8: point_clouds_evaluation ==="
echo "Building Docker image '$IMAGE_NAME'..."
docker build -t "$IMAGE_NAME" . || exit 1

mkdir -p "$OUT_DIR"

CSV_HEADER="scan_id,submap_id,overall_cd,pc1_to_pc2,pc2_to_pc1,hausdorff_distance,rmse,precision,recall,f_score"


to_container_path() {
    echo "/data/${1#"$DATA_ROOT"/}"
}


run_metrics() {
    docker run --rm \
        --user "$(id -u):$(id -g)" \
        -e HOME=/tmp \
        -v "$DATA_ROOT":/data \
        -w /data \
        --entrypoint python \
        "$IMAGE_NAME" \
        /app/point_clouds_evaluation/pointcloud_metrics.py "$@"
}


compare_pair() {
    local csv_file="$1"
    local scan_file="$2"
    local submap_file="$3"
    local scan_id="$4"
    local submap_id="$5"

    echo "=========================================="
    echo "Comparing:"
    echo "  Scan:   $scan_id"
    echo "  Submap: $submap_id"
    echo "=========================================="

    local tmp_file
    tmp_file=$(mktemp)

    run_metrics \
        "$(to_container_path "$scan_file")" \
        "$(to_container_path "$submap_file")" \
        --threshold "$THRESHOLD" | tee "$tmp_file"

    python3 - "$csv_file" "$scan_id" "$submap_id" "$tmp_file" <<'PY'
import sys
import csv

csv_file, scan_id, submap_id, output_file = sys.argv[1:5]

metrics = {}

with open(output_file, encoding="utf-8") as f:
    for line in f:
        line = line.strip()

        if ":" not in line:
            continue

        name, value = line.split(":", 1)
        name = name.strip()
        value = value.strip()

        if value:
            metrics[name] = value.split()[0]

with open(csv_file, "a", newline="", encoding="utf-8") as f:
    csv.writer(f).writerow([
        scan_id,
        submap_id,
        metrics.get("Overall CD", ""),
        metrics.get("PC1 → PC2", ""),
        metrics.get("PC2 → PC1", ""),
        metrics.get("Hausdorff Distance", ""),
        metrics.get("RMSE", ""),
        metrics.get("Precision", ""),
        metrics.get("Recall", ""),
        metrics.get("F-score", ""),
    ])
PY

    rm -f "$tmp_file"
}


# ============================================================
# optimized-sc-f-loam
# ============================================================

DATA_DIR="$DATA_ROOT/optimized-sc-f-loam-loop"
CSV_SC_F_LOAM="$OUT_DIR/$(basename "$DATA_DIR").csv"

echo "$CSV_HEADER" > "$CSV_SC_F_LOAM"

i=0
while true; do
    scan_file="$DATA_DIR/loop_scan_${i}.ply"
    submap_file="$DATA_DIR/loop_submap_${i}.ply"

    if [ ! -f "$scan_file" ] || [ ! -f "$submap_file" ]; then
        echo "Finished optimized-sc-f-loam at index $((i - 1))"
        break
    fi

    compare_pair "$CSV_SC_F_LOAM" "$scan_file" "$submap_file" \
        "loop_scan_${i}" "loop_submap_${i}"

    i=$((i + 1))
done


# ============================================================
# pin-slam
# ============================================================

DATA_DIR="$DATA_ROOT/pin-slam-loop"
CSV_PIN_SLAM="$OUT_DIR/$(basename "$DATA_DIR").csv"

echo "$CSV_HEADER" > "$CSV_PIN_SLAM"

for scan_file in "$DATA_DIR"/*_current_*_global.ply; do
    [ -f "$scan_file" ] || continue

    submap_file="${scan_file/_current_/_history_}"

    if [ ! -f "$submap_file" ]; then
        echo "Brak history dla: $(basename "$scan_file")"
        continue
    fi

    compare_pair "$CSV_PIN_SLAM" "$scan_file" "$submap_file" \
        "$(basename "$scan_file" .ply)" "$(basename "$submap_file" .ply)"
done


# ============================================================
# Markdown + LaTeX
# ============================================================
docker run --rm \
    --user "$(id -u):$(id -g)" \
    -e HOME="$HOME" \
    -v "$DATA_ROOT":"$DATA_ROOT" \
    --entrypoint python \
    "$IMAGE_NAME" \
    /app/metrics_tables.py

echo ""
echo "Results saved to:"
echo "$CSV_SC_F_LOAM"
echo "$CSV_PIN_SLAM"
echo "$OUT_DIR/pointcloud_metrics_results.md"
echo "$OUT_DIR/pointcloud_metrics_results.tex"

echo "=== DONE ==="