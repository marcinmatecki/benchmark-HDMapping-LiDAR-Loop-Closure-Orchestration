# Clone repositories and build Docker images

Clones the HDMapping benchmark repositories of the evaluated loop closure
frameworks from [MapsHD](https://github.com/MapsHD), switches all of them to the
same branch and builds a Docker image for each framework.

## Usage

```bash
chmod +x clone_github_repositories_step2.sh
./clone_github_repositories_step2.sh [branch_name]
```

Example:

```bash
./clone_github_repositories_step2.sh main
```


## What the script does

1. Creates `~/hdmapping-benchmark-loop-closure` (if it does not exist) and
   clones the repositories into it.
2. For every repository:
   - clones it with submodules (skipped if it already exists),
   - fetches and checks out the selected branch,
   - fast-forwards it to the remote branch (`git pull --ff-only`); local
     commits are never overwritten — if the pull fails, a warning is printed and
     the local state is used,
   - updates submodules.
3. Builds a Docker image for every framework.

## Repositories and Docker images

| Framework | Repository | Docker image |
|---|---|---|
| Optimized SC-F-LOAM (ROS 1 Noetic) | [benchmark-Optimized-SC-F-LOAM-to-HDMapping](https://github.com/MapsHD/benchmark-Optimized-SC-F-LOAM-to-HDMapping) | `optimized-sc-f-loam_noetic` |
| PIN-SLAM (Python) | [benchmark-PIN-SLAM-to-HDMapping](https://github.com/MapsHD/benchmark-PIN-SLAM-to-HDMapping) | `pin-slam_cuda` |

## Resulting layout

```
~/hdmapping-benchmark-loop-closure/
├── benchmark-Optimized-SC-F-LOAM-to-HDMapping/
├── benchmark-PIN-SLAM-to-HDMapping/
└── data/            # created by the dataset download script
```
