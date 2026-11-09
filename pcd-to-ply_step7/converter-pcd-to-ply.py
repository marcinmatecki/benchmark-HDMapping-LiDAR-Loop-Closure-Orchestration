import open3d as o3d
from pathlib import Path

DATA = Path("/data").expanduser()

jobs = {
    DATA / "optimized-sc-f-loam/output_hdmapping-optimized-sc-f-loam":
        DATA / "optimized-sc-f-loam-loop",

    DATA / "pin-slam/loop_clouds_global":
        DATA / "pin-slam-loop",
}

for src_dir, dst_dir in jobs.items():
    dst_dir.mkdir(parents=True, exist_ok=True)

    for pcd in src_dir.rglob("*.pcd"):
        ply = dst_dir / f"{pcd.stem}.ply"

        print(f"{pcd} -> {ply}")

        cloud = o3d.io.read_point_cloud(str(pcd))

        if cloud.is_empty():
            print(f"WARNING: failed to read {pcd}")
            continue

        o3d.io.write_point_cloud(str(ply), cloud)

print("Gotowe.")