# Loop closure evaluation on trajectory

Evaluates the loop closures detected by each framework against the
ground-truth trajectory: every detected loop edge is classified as a true or
false positive, missed ground-truth revisits are counted as false negatives,
and precision, recall and F1-score are computed.


## Usage

```bash
chmod +x run_loop_closure_eval.sh
./run_loop_closure_eval.sh
```

The script takes no arguments. It builds the Docker image `loop-closure-eval`
and runs three steps inside it, with
`~/hdmapping-benchmark-loop-closure/data` mounted as `/data`:

1. `loop_clouds_to_edges.py` – prepares the loop edge files,
2. `plot_gt.py` – plots the ground-truth trajectory,
3. `compare_loop_edges.py` – evaluates each framework.


## Step 1 – Loop edges (`loop_clouds_to_edges.py`)

Converts the loop closures of each framework to a common CSV format
(`current_id, history_id, current_time, history_time`, time in seconds).
Duplicate edges are removed.

| Framework | Input | Output |
|---|---|---|
| Optimized SC-F-LOAM | `data/optimized-sc-f-loam/output_hdmapping-optimized-sc-f-loam/loop_constraints.csv` | `data/tum/sc_f_loam_edges.csv` |
| PIN-SLAM | `data/pin-slam/loop_clouds/loop_constraints.csv` | `data/tum/pin_slam_edges.csv` |

For SC-F-LOAM, every scan with id `k` is paired with the submap with id `k`.

## Step 2 – Ground-truth plot (`plot_gt.py`)

Plots the ground-truth trajectory in the XY plane with the start and end
points and the ground-truth revisits (places where a loop should be detected).
Prints the number of poses, duration, length and frequency of the trajectory.

```bash
python3 plot_gt.py ground_truth.tum --save gt.png --no_show
```

| Option | Default | Description |
|---|---|---|
| `--dist` | 5.0 | max distance [m] for a ground-truth revisit |
| `--min_dt` | 30.0 | min time gap [s] for a ground-truth revisit |
| `--no_gt_loops` | – | do not draw ground-truth revisits |
| `--time_z` | – | 3D view, Z axis = time |
| `--title` | none | plot title |
| `--dpi` | 300 | image resolution |
| `--save` | – | output file (`.png`, `.pdf`, `.svg`) |
| `--no_show` | – | do not open the plot window |

## Step 3 – Evaluation (`compare_loop_edges.py`)

```bash
python3 compare_loop_edges.py ground_truth.tum edges.csv \
    --t_offset_from trajectory_tum.txt --name <framework> \
    --csv metrics.csv --save loops.png --no_show
```

### Method

1. **Time alignment.** The edge timestamps are shifted to the ground-truth
   time base. With `--t_offset_from`, the offset is computed as
   `first GT timestamp − first timestamp of the given TUM trajectory`, so the
   first pose of the framework's trajectory corresponds to the first
   ground-truth pose.
2. **Association.** Both scans of an edge are associated with the temporally
   nearest ground-truth poses. Edges with no pose within `--t_max_diff`
   are discarded.
3. **TP / FP.** An edge is a true positive (TP) if the ground-truth distance
   between its two poses is smaller than `--dist`, otherwise a false
   positive (FP).
4. **Ground-truth revisits.** A ground-truth pose is a revisit if a previously
   visited pose lies closer than `--dist` and the two poses are more than
   `--min_dt` apart in time. A revisit is detected if it is the later scan of
   at least one TP edge, otherwise it is a false negative (FN).

### Metrics

```
Precision = TP / (TP + FP)          computed over loop edges
Recall    = TP / (TP + FN)          computed over ground-truth revisits
F1-score  = 2 · P · R / (P + R)
```

### Options

| Option | Default | Description |
|---|---|---|
| `--dist` | 5.0 | max ground-truth distance [m] for a true loop |
| `--min_dt` | 30.0 | min time gap [s] for a ground-truth revisit |
| `--t_offset` | 0.0 | time offset [s] added to edge timestamps |
| `--t_offset_from` | – | compute the offset from a TUM trajectory (overrides `--t_offset`) |
| `--t_max_diff` | 0.2 | max time difference [s] when matching edges to GT poses |
| `--csv` | `metrics.csv` | metrics file (a row is appended for each run) |
| `--name` | edge file name | framework name in the CSV |
| `--save` | – | save the plot to a file |
| `--no_show` | – | do not open the plot window |
| `--time_z` | – | 3D view, Z axis = time |
| `--no_gt_loops` | – | do not draw ground-truth revisits |
| `--labels` | – | label edges with their ids |

### Plot

- blue – ground-truth trajectory
- green – TP edges
- red – FP edges
- gray – ground-truth revisits (expected loops)
- circle / square – current / history scan of an edge

The title shows TP, FP, precision, recall and F1-score. FP edges are also
printed to the terminal with their ground-truth distance.

## Output

Saved to `data/tum/loop-closure-results/`:

| File | Content |
|---|---|
| `metrics.csv` | one row per framework |
| `gt_trajectory.png` | ground-truth trajectory |
| `pin_slam_result.png`, `sc_f_loam_result.png` | loop edges over the GT trajectory |

`metrics.csv` columns:

| Column | Meaning |
|---|---|
| `method` | framework name |
| `edges_total` | number of loop edges in the input file |
| `edges_matched` | edges matched to ground-truth poses in time |
| `tp`, `fp` | true / false positive edges |
| `tp_scans` | detected ground-truth revisits |
| `fn_scans` | missed ground-truth revisits |
| `gt_revisit_scans` | all ground-truth revisits |
| `precision`, `recall`, `fscore` | metrics |
| `dist`, `min_dt`, `t_offset` | parameters used |