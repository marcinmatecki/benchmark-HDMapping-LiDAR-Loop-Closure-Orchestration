# Convert results to TUM format

Converts the trajectories produced by the evaluated frameworks (HDMapping
sessions) to the TUM trajectory format.

## Usage

```bash
chmod +x convert_to_tum.sh
./convert_to_tum.sh
```

Processed frameworks:

```
optimized-sc-f-loam
pin-slam
```

## Output

```
data/
├── backup/
│   ├── optimized-sc-f-loam_backup/
│   └── pin-slam_backup/
└── tum/
    ├── ground_truth.tum
    ├── output_hdmapping-<framework>_trajectory_tum.txt
    └── output_hdmapping-<framework>_trajectory_tum-local-zero.txt
