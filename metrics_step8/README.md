# Point cloud metrics tables

Converts the point cloud metrics computed for each loop closure into Markdown
and LaTeX tables. 


## Usage

```bash
python3 metrics_tables.py
```

The script takes no arguments.

## Input

| Framework | File |
|---|---|
| Optimized SC-F-LOAM | `data/tum/optimized-sc-f-loam-loop.csv` |
| PIN-SLAM | `data/tum/pin-slam-loop.csv` |

The first line of each CSV (header) is skipped; the columns must be in the
following order. A missing file is reported and skipped.

| Column | Meaning |
|---|---|
| `Scan` | current scan of the loop closure |
| `Submap` | matched submap (history) |
| `CD` | Chamfer distance between the scan (PC1) and the submap (PC2) |
| `CD PC1-PC2` | one-directional Chamfer distance, scan → submap |
| `CD PC2-PC1` | one-directional Chamfer distance, submap → scan |
| `Hausdorff` | Hausdorff distance |
| `RMSE` | root mean square error of point-to-point distances |
| `Precision` | fraction of scan points closer to the submap than a threshold |
| `Recall` | fraction of submap points closer to the scan than a threshold |
| `F-score` | harmonic mean of point cloud precision and recall |

Precision, recall and F-score here describe the **geometric agreement of the
two point clouds** of a loop closure.

## Output

Saved to `data/tum/`:

| File | Content |
|---|---|
| `pointcloud_metrics_results.md` | one Markdown table per framework |
| `pointcloud_metrics_results.tex` | one LaTeX table per framework  |

