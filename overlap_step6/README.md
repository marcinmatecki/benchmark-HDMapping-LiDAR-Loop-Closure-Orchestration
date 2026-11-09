# Overlap analysis

Checks how much of the ground-truth sequence each framework actually
processed. A framework may start late, stop early or drop frames — such a
trajectory could otherwise get misleadingly good accuracy scores.

## Requirements

- Python 3 (standard library only, no Docker needed)
- trajectories converted to TUM (`convert_to_tum.sh`)

## Usage

```bash
python3 overlap.py
```

The script takes no arguments.

## Input

Read from `~/hdmapping-benchmark-loop-closure/data/tum/`:

```
ground_truth.tum
output_hdmapping-<framework>_trajectory_tum-local-zero.txt
```

## Metrics

For each trajectory, the first and last timestamp and the number of poses are
read and compared with the ground truth (GT):

| Metric | Formula | Meaning |
|---|---|---|
| Metric 1 – time coverage [%] | (t_end − t_begin) / (t_end_GT − t_begin_GT) · 100 | duration of the trajectory relative to the GT duration |
| Metric 2 – node ratio [%] | N / N_GT · 100 | number of poses relative to the number of GT poses |

## Output

Results are printed to the terminal and saved to `data/tum/`:

| File | Content |
|---|---|
| `overlap_results.md` | Markdown table |
| `overlap_results.tex` | LaTeX table (`tab:lio_overlap`) |

Table columns: `Algorithm`, `Metric1 [%]`, `Metric2 [%]`, `Nodes`.