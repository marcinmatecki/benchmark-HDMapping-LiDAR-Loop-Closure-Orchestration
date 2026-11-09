# PCD to PLY conversion

Converts the loop closure point clouds saved by the frameworks from PCD
(Point Cloud Library format) to PLY, so they can be opened in common viewers
(e.g. CloudCompare, MeshLab, HDMapping) and compared side by side.


The script uses the path `/data`, so it is meant to be run inside a Docker
container with the data directory mounted:

```bash
docker run --rm \
    --user 1000:1000 \
    -v ~/hdmapping-benchmark-loop-closure/data:/data \
    -w /data \
    <image_with_open3d> \
    python3 /app/pcd_to_ply.py
```

## Input and output

All `*.pcd` files found recursively in the input directory are converted:

| Framework | Input (PCD) | Output (PLY) |
|---|---|---|
| Optimized SC-F-LOAM | `data/optimized-sc-f-loam/output_hdmapping-optimized-sc-f-loam/` | `data/optimized-sc-f-loam-loop/` |
| PIN-SLAM | `data/pin-slam/loop_clouds_global/` | `data/pin-slam-loop/` |

Each `<name>.pcd` is saved as `<name>.ply` directly in the output directory
(subdirectories are not kept). Output directories are created automatically.

