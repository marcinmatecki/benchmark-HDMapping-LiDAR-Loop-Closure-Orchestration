# HDMapping Loop Closure Benchmark

# Option 1 (Full automation)

## Step 1 - Prepare data

The required KITTI data will be downloaded and prepared automatically.

## Step 2 - Clone repositories

```shell
mkdir -p ~/hdmapping-benchmark-loop-closure
cd ~/hdmapping-benchmark-loop-closure

git clone https://github.com/MapsHD/benchmark-HDMapping-LiDAR-Loop-Closure-Orchestration.git

cd benchmark-HDMapping-LiDAR-Loop-Closure-Orchestration
```

## Step 3 - Make scripts executable

```shell
chmod +x prepare_data_step1/prepare_data_step1.sh
chmod +x clone_github_repositories_step2/clone_github_repositories_step2.sh
chmod +x traditional_loop_closure_methods_step3/run_benchmark_traditional.sh
chmod +x ai_loop_closure_methods_step4/run_benchmark_AI.sh
chmod +x open3d_loop_closure_step5/run_benchmark_Open3D.sh
chmod +x start_benchmark.sh
```

## Step 4 - Run the complete benchmark

```shell
./start_benchmark.sh
```

The script automatically runs:

1. Prepare data
2. Clone repositories and build Docker images
3. Run traditional loop-closure methods
4. Run AI loop-closure methods
5. Run Open3D loop closure

Results are stored in:

```shell
~/hdmapping-benchmark-loop-closure/data
```

This repository provides an orchestration framework for benchmarking
different loop closure methods used in HDMapping and LiDAR-based mapping
systems.

The benchmark is organized into five steps:

1. **Prepare Data**
2. **Clone Repositories**
3. **Traditional Loop Closure Methods**
4. **AI Loop Closure Methods**
5. **Open3D Loop Closure**

The goal is to provide a common dataset and a reproducible environment
for comparing different loop closure approaches.

---

# Repository Structure

```text
- prepare_data_step1/
- clone_github_repositories_step2/
- traditional_loop_closure_methods_step3/
- ai_loop_closure_methods_step4/
- open3d_loop_closure_step5/
