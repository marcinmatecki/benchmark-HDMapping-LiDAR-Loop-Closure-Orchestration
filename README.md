# HDMapping LiDAR Loop Closure Benchmark – Orchestration

Benchmark of LiDAR loop closure detection frameworks on KITTI.
The pipeline downloads the data, runs every framework in Docker, converts the
results and evaluates trajectories, point clouds and loop closures.


## Evaluated frameworks

| Framework | Approach | License | Commercial use | Year |
|---|---|---|---|---|
| [PIN-SLAM](https://github.com/PRBonn/PIN_SLAM) | Loop Closure Detection | MIT | Yes | 2024 |
| [Optimized SC-F-LOAM](https://github.com/SlamCabbage/Optimized-SC-F-LOAM) | Loop Closure Detection | BSD-3-Clause | Restricted* | 2022 |

\* The Scan Context module is licensed under CC BY-NC-SA 4.0 (non-commercial use only).

## Requirements

- Linux
- `git`, `wget`, `docker` (runnable without `sudo`)
- Python 3
- an X server for interactive plots (optional)
- enough disk space for the KITTI bags and results

## Quick start

```bash
mkdir -p ~/hdmapping-benchmark-loop-closure
cd ~/hdmapping-benchmark-loop-closure
git clone https://github.com/MapsHD/benchmark-HDMapping-LiDAR-LoopClosure-Orchestration.git --recursive
cd benchmark-HDMapping-LiDAR-LoopClosure-Orchestration
chmod +x start_benchmark.sh
./start_benchmark.sh
```

`start_benchmark.sh` runs the steps one after another (with a 5 s pause between
them) and stops at the first error. Steps can be skipped by commenting them
out in the script, e.g. after the data has already been downloaded and the
frameworks have been run.

## Pipeline

| Step | Folder | Script | Description |
|---|---|---|---|
| 1 | `prepare_data_step1` | `download_data.sh seq05` | download a KITTI sequence as a ROS 1 bag |
| 2 | `clone_github_repositories_step2` | `clone_github_repositories_step2.sh kitti` | clone the framework repositories (branch `kitti`) and build their Docker images |
| 3 | `run_benchmark_step3` | `run_benchmark_step3.sh` | run all frameworks on the bag |
| 4 | `conversion_tum_step4` | `run_tum_step4.sh` | convert the trajectories to TUM format |
| 5 | `evo_step5` | `tum-to-latex_step5.sh` | APE / RPE evaluation with evo |
| 6 | `overlap_step6` | `overlap.py` | time coverage and node ratio |
| 7 | `pcd-to-ply_step7` | `converter-pcd-to-ply-step7.sh` | convert loop closure point clouds from PCD to PLY |
| 8 | `metrics_step8` | `metrics-step8.sh` | point cloud metrics tables |
| 9 | `loop-closure-eval_step9` | `run_loop_closure_eval.sh` | loop closure evaluation on the GT trajectory (precision, recall, F1) |

Each folder contains its own README with details.

## Directory layout

```
~/hdmapping-benchmark-loop-closure/
├── benchmark-HDMapping-LiDAR-LoopClosure-Orchestration/   # this repository
├── benchmark-optimized-sc-f-loam-to-HDMapping/            # step 2
├── benchmark-PIN-SLAM-to-HDMapping/                       # step 2
└── data/                                                  # mounted as /data in Docker
    ├── kitti_seqXX_ros1.bag                               # step 1
    ├── optimized-sc-f-loam/                               # step 3
    ├── pin-slam/                                          # step 3
    ├── backup/                                            # step 4
    ├── optimized-sc-f-loam-loop/, pin-slam-loop/          # step 7
    └── tum/
        ├── ground_truth.tum
        ├── output_hdmapping-<framework>_trajectory_tum*.txt   # step 4
        ├── table_ape.*, table_rpe.*                           # step 5
        ├── overlap_results.*                                  # step 6
        ├── pointcloud_metrics_results.*                       # step 8
        └── loop-closure-results/                              # step 9
```

## Results

| Step | Output |
|---|---|
| 5 | `table_ape.{csv,tex}`, `table_rpe.{csv,tex}`, `ape_table_github.md`, `rpe_table_github.md` |
| 6 | `overlap_results.{md,tex}` |
| 8 | `pointcloud_metrics_results.{md,tex}` |
| 9 | `loop-closure-results/metrics.csv`, plots of loop edges and the GT trajectory |

All files are saved in `data/tum/`.

## Citation

Thanks to the authors of the following works:

```bibtex
@article{pan2024pinslam,
  author  = {Pan, Yue and Zhong, Xingguang and Wiesmann, Louis and Posewsky, Thorbj{\"o}rn and Behley, Jens and Stachniss, Cyrill},
  title   = {{PIN-SLAM}: {LiDAR} {SLAM} Using a Point-Based Implicit Neural Representation for Achieving Global Map Consistency},
  journal = {IEEE Transactions on Robotics},
  year    = {2024}
}

@inproceedings{liao2022optimizedscfloam,
  author    = {Liao, Lizhou and Fu, Chunyun and Feng, Binbin and Su, Tian},
  title     = {Optimized {SC-F-LOAM}: Optimized Fast {LiDAR} Odometry and Mapping Using Scan Context},
  booktitle = {6th CAA International Conference on Vehicular Control and Intelligence (CVCI)},
  year      = {2022},
  doi       = {10.1109/CVCI56766.2022.9964574}
}

@inproceedings{kim2018scancontext,
  author    = {Kim, Giseop and Kim, Ayoung},
  title     = {Scan Context: Egocentric Spatial Descriptor for Place Recognition within {3D} Point Cloud Map},
  booktitle = {IEEE/RSJ International Conference on Intelligent Robots and Systems (IROS)},
  year      = {2018}
}

@inproceedings{geiger2012kitti,
  author    = {Geiger, Andreas and Lenz, Philip and Urtasun, Raquel},
  title     = {Are we ready for Autonomous Driving? The {KITTI} Vision Benchmark Suite},
  booktitle = {IEEE Conference on Computer Vision and Pattern Recognition (CVPR)},
  year      = {2012}
}

@misc{grupp2017evo,
  title        = {evo: Python package for the evaluation of odometry and SLAM},
  author       = {Grupp, Michael},
  howpublished = {\url{https://github.com/MichaelGrupp/evo}},
  year         = {2017}
}
```