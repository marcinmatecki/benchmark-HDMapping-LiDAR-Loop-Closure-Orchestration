# Run the benchmark

Runs every evaluated loop closure framework on one ROS 1 bag and stores the
results of each framework in its own output directory.

## Usage

```bash
chmod +x run_benchmark.sh
.run_benchmark_step3.sh <ros1_bag> <output_dir>
```

| Argument | Description |
|---|---|
| `ros1_bag` | path to a ROS 1 `.bag` file |
| `output_dir` | directory where the results are stored (created if it does not exist) |

Example:

```bash
.run_benchmark_step3.sh \
    ~/hdmapping-benchmark-loop-closure/data/kitti_seq00_ros1.bag \
    ~/hdmapping-benchmark-loop-closure/data
```

Use `~/hdmapping-benchmark-loop-closure/data` as `output_dir`: the evaluation
scripts read the results from this directory (mounted as `/data` in Docker).


## What the script does

The frameworks are run one after another, with a 5 s pause before each run.
Each framework is started by the run script from its own repository:

| Framework | Repository | Run script |
|---|---|---|
| Optimized SC-F-LOAM (ROS 1) | `benchmark-optimized-sc-f-loam-to-HDMapping` | `docker_session_run-ros1-optimized-sc-f-loam.sh` |
| PIN-SLAM | `benchmark-PIN-SLAM-to-HDMapping` | `docker_session_run-pin-slam.sh` |

Both paths are converted to absolute paths, so relative paths can be used.

## Output

```
<output_dir>/
├── optimized-sc-f-loam/
│   └── output_hdmapping-optimized-sc-f-loam/
│       └── loop_constraints.csv
└── pin-slam/
    ├── pin_experiments/
    └── loop_clouds/
        └── loop_constraints.csv
```

## Adding a framework

Add the repository name and the framework name at the same position in
`ROS1_REPOS` / `ROS1_ALGOS` (ROS 1 frameworks) or `ROS_REPOS` / `ROS_ALGOS`
(other frameworks). The repository must provide the run script
`docker_session_run-ros1-<algo>.sh` or `docker_session_run-<algo>.sh`,
respectively, taking `<input_bag> <output_dir>` as arguments.