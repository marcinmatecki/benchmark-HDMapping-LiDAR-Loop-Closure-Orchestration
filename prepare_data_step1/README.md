# KITTI dataset download

Downloads a KITTI odometry sequence converted to a ROS 1 bag, used as input
for the loop closure benchmark.

The bags come from the Hugging Face dataset
[kubchud/kitti_to_ros](https://huggingface.co/datasets/kubchud/kitti_to_ros).

## Requirements

- `wget`
- enough free disk space (each bag is several GB)

## Usage

```bash
chmod +x download_kitti.sh
./download_kitti.sh seqXX
```

Example:

```bash
./download_kitti.sh seq00
```

Available sequences:

```
seq00 seq01 seq02 seq04 seq05 seq06 seq07 seq08 seq09 seq10
```


## Output

The bag is saved to:

```
~/hdmapping-benchmark-loop-closure/data/kitti_seqXX_ros1.bag
```

The `data` directory is created automatically if it does not exist.
This is the same directory that is mounted as `/data` in the Docker containers
of the benchmark.

## Notes

- The download uses `wget -c`, so an interrupted download can be resumed by
  running the same command again.
- Running the script without an argument, or with an unsupported sequence,
  prints the usage and the list of available sequences.

## License

KITTI is released under the
[Creative Commons Attribution-NonCommercial-ShareAlike 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/)
license. If you use it, please cite:

```bibtex
@inproceedings{geiger2012kitti,
  author    = {Geiger, Andreas and Lenz, Philip and Urtasun, Raquel},
  title     = {Are we ready for Autonomous Driving? The KITTI Vision Benchmark Suite},
  booktitle = {IEEE Conference on Computer Vision and Pattern Recognition (CVPR)},
  year      = {2012}
}
```