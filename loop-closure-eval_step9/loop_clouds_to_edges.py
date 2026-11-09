#!/usr/bin/env python3
"""
Prepare loop-edge files for compare_loop_edges.py.

SC-F-LOAM: loop_clouds.csv (type,id,timestamp_ns,filename,points)
  Pair: scan with id=k  <->  submap with id=k
    current_time = scan timestamp   [s]
    history_time = submap timestamp [s]  (time of the historical keyframe)
  Repeated pairs (same scan and submap, e.g. ids 30-38) are removed.

PIN-SLAM: loop_constraints.csv
  (current_id,history_id,current_time,history_time,tx,ty,tz,roll,pitch,yaw)
  Already in edge format - copied as is, without duplicates.

Output:
  /data/tum/sc_f_loam_edges.csv
  /data/tum/pin_slam_edges.csv

Usage (inside the container, data mounted at /data):
  python3 loop_clouds_to_edges.py
"""

import csv
import os

DATA_DIR = "/data"
OUTPUT_DIR = "/data/tum"

SC_F_LOAM_INPUT = "/data/optimized-sc-f-loam/output_hdmapping-optimized-sc-f-loam/loop_constraints.csv"
SC_F_LOAM_OUTPUT = os.path.join(OUTPUT_DIR, "sc_f_loam_edges.csv")

PIN_SLAM_INPUT = "/data/pin-slam/loop_clouds/loop_constraints.csv"
PIN_SLAM_OUTPUT = os.path.join(OUTPUT_DIR, "pin_slam_edges.csv")


# ============================================================
# SC-F-LOAM
# ============================================================
def convert_sc_f_loam():
    print("=== SC-F-LOAM ===")

    if not os.path.isfile(SC_F_LOAM_INPUT):
        print(f"File not found: {SC_F_LOAM_INPUT}")
        return

    scans, submaps = {}, {}
    with open(SC_F_LOAM_INPUT) as f:
        for r in csv.DictReader(f):
            d = scans if r["type"].strip() == "scan" else submaps
            d[int(r["id"])] = int(r["timestamp_ns"])

    seen = set()
    out = []
    for k in sorted(scans):
        if k not in submaps:
            print(f"[WARNING] no submap for scan id {k}")
            continue
        key = (scans[k], submaps[k])
        if key in seen:
            continue
        seen.add(key)
        out.append((k, scans[k] / 1e9, submaps[k] / 1e9))

    with open(SC_F_LOAM_OUTPUT, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["current_id", "history_id", "current_time", "history_time"])
        for k, ct, ht in out:
            w.writerow([k, k, f"{ct:.9f}", f"{ht:.9f}"])

    print(f"Input:            {SC_F_LOAM_INPUT}")
    print(f"Pairs in file:    {len(scans)}")
    print(f"Unique edges:     {len(out)}  (removed {len(scans) - len(out)} duplicates)")
    print(f"Saved: {SC_F_LOAM_OUTPUT}")


# ============================================================
# PIN-SLAM
# ============================================================
def convert_pin_slam():
    print("=== PIN-SLAM ===")

    pin_input = PIN_SLAM_INPUT
    if not os.path.isfile(pin_input):
        print(f"File not found: {pin_input}")
        return

    with open(pin_input) as f:
        reader = csv.DictReader(f)
        header = reader.fieldnames
        rows = list(reader)

    seen = set()
    out = []
    for r in rows:
        key = (r["current_time"].strip(), r["history_time"].strip())
        if key in seen:
            continue
        seen.add(key)
        out.append(r)

    with open(PIN_SLAM_OUTPUT, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=header)
        w.writeheader()
        w.writerows(out)

    print(f"Input:            {pin_input}")
    print(f"Edges in file:    {len(rows)}")
    print(f"Unique edges:     {len(out)}  (removed {len(rows) - len(out)} duplicates)")
    print(f"Saved: {PIN_SLAM_OUTPUT}")


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    convert_sc_f_loam()
    print("")
    convert_pin_slam()


if __name__ == "__main__":
    main()