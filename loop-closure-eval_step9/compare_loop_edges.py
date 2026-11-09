#!/usr/bin/env python3
"""
Visualize SLAM loop-closure edges (loop_constraints.csv) over the GT trajectory,
and save precision / recall / F-score metrics to CSV.

  green - TP: according to GT, the two scans were closer than --dist
  red   - FP: according to GT, the scans were far apart (false loop)
  gray  - GT revisits: poses where GT has a loop (dist < --dist, dt > --min_dt)

Metrics:
  precision = TP / (TP + FP)   - fraction of detected loop edges that are real
  recall    = TP / (TP + FN)   - fraction of GT revisit scans that were detected
              (a GT revisit scan counts as TP if it is the later scan of some
               TP edge; every GT revisit scan without a TP edge is a FN)
  fscore    = 2 * P * R / (P + R)

Usage:
  python3 compare_loop_edges.py ground_truth.tum loop_constraints.csv --t_offset=-1317383678.919233799
  python3 compare_loop_edges.py ground_truth.tum loop_constraints.csv --t_offset_from trajectory_tum.txt
  python3 compare_loop_edges.py ... --csv metrics.csv --name sc_f_loam
  python3 compare_loop_edges.py ... --save loops.png --no_show
"""

import argparse
import csv
import os
import sys

import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from matplotlib.collections import LineCollection
from matplotlib.lines import Line2D
from scipy.spatial import cKDTree


def nearest_idx(t_sorted, t_query):
    idx = np.searchsorted(t_sorted, t_query)
    idx = np.clip(idx, 1, len(t_sorted) - 1)
    left = t_sorted[idx - 1]
    right = t_sorted[idx]
    idx -= (t_query - left) < (right - t_query)
    return idx


def col(rows, *names):
    for n in names:
        if n in rows[0]:
            return np.array([float(r[n]) for r in rows])
    sys.exit(f"Missing column: {' / '.join(names)} (found: {', '.join(rows[0].keys())})")


def first_timestamp(path):
    """First timestamp in a TUM file: first column of the first non-comment line."""
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            tok = line.replace(",", " ").split()[0]
            try:
                return float(tok)
            except ValueError:
                continue  # header line
    sys.exit(f"No timestamp found in: {path}")


def gt_loop_indices(gt, t_gt, dist, min_dt):
    """Indices of GT poses that revisit a previously visited place."""
    pairs = cKDTree(gt[:, 1:4]).query_pairs(r=dist, output_type="ndarray")
    if not len(pairs):
        return np.array([], dtype=int)
    a = np.minimum(pairs[:, 0], pairs[:, 1])
    b = np.maximum(pairs[:, 0], pairs[:, 1])
    return np.unique(b[(t_gt[b] - t_gt[a]) > min_dt])


def f1(p, r):
    return 2 * p * r / (p + r) if (p + r) > 0 else 0.0


def compute_metrics(tp, fp, hi, ci, gt_loop):
    n_tp, n_fp = int(tp.sum()), int(fp.sum())
    precision = n_tp / (n_tp + n_fp) if (n_tp + n_fp) else 0.0

    # recall per scan: TP / (TP + FN)
    # positives = GT revisit poses; a revisit is detected if it is the later
    # scan of at least one TP edge
    revisit = np.maximum(hi[tp], ci[tp])
    tp_scans = int(np.intersect1d(np.unique(revisit), gt_loop).size)
    fn_scans = int(len(gt_loop) - tp_scans)
    recall = tp_scans / (tp_scans + fn_scans) if (tp_scans + fn_scans) else 0.0

    return {
        "tp": n_tp,
        "fp": n_fp,
        "tp_scans": tp_scans,
        "fn_scans": fn_scans,
        "gt_revisit_scans": int(len(gt_loop)),
        "precision": precision,
        "recall": recall,
        "fscore": f1(precision, recall),
    }


def write_csv(path, row):
    new = not os.path.exists(path) or os.path.getsize(path) == 0
    with open(path, "a", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(row.keys()))
        if new:
            w.writeheader()
        w.writerow(row)


def main():
    ap = argparse.ArgumentParser(description="Evaluate loop-closure edges against a GT trajectory.")
    ap.add_argument("gt_tum", help="GT trajectory in TUM format")
    ap.add_argument("edges_csv", help="CSV with loop edges (history_time, current_time)")
    ap.add_argument("--dist", type=float, default=5.0,
                    help="max GT distance [m] for a true loop (default 5.0)")
    ap.add_argument("--min_dt", type=float, default=30.0,
                    help="min time gap [s] between scans for a GT revisit (default 30.0)")
    ap.add_argument("--t_offset", type=float, default=0.0,
                    help="offset [s] added to edge timestamps to match GT time")
    ap.add_argument("--t_offset_from",
                    help="compute offset from a file: t_offset = first GT time - first time in "
                         "this file (e.g. a TUM trajectory starting at the first scan); "
                         "overrides --t_offset")
    ap.add_argument("--t_max_diff", type=float, default=0.2,
                    help="max time difference [s] when matching edges to GT poses (default 0.2)")
    ap.add_argument("--csv", default="metrics.csv",
                    help="metrics CSV file (a row is appended, default metrics.csv)")
    ap.add_argument("--name", help="method name in CSV (default: edges file name)")
    ap.add_argument("--time_z", action="store_true", help="3D view, Z axis = time")
    ap.add_argument("--no_gt_loops", action="store_true", help="do not draw gray GT revisits")
    ap.add_argument("--labels", action="store_true", help="label edges with ids")
    ap.add_argument("--save", help="save plot to PNG")
    ap.add_argument("--no_show", action="store_true", help="do not open plot window")
    args = ap.parse_args()

    if args.no_show:
        matplotlib.use("Agg")

    gt = np.loadtxt(args.gt_tum, comments="#")
    t_gt, xy = gt[:, 0], gt[:, 1:3]
    tt = t_gt - t_gt[0]

    if args.t_offset_from:
        t0_ref = first_timestamp(args.t_offset_from)
        args.t_offset = t_gt[0] - t0_ref
        print(f"t_offset from: {args.t_offset_from}")

    with open(args.edges_csv) as f:
        rows = list(csv.DictReader(f))
    if not rows:
        sys.exit(f"Empty file: {args.edges_csv}")
    hist_t = col(rows, "history_time", "hist_t") + args.t_offset
    curr_t = col(rows, "current_time", "curr_t") + args.t_offset
    cur_id = [r.get("current_id", "") for r in rows]
    his_id = [r.get("history_id", "") for r in rows]

    # edge times relative to GT start (seconds into the sequence)
    rel_c, rel_h = curr_t - t_gt[0], hist_t - t_gt[0]
    print(f"Edge times after offset (GT time, 0 = sequence start, GT ends at {tt[-1]:.2f} s):")
    for k in range(min(5, len(rows))):
        print(f"  edge {cur_id[k]}-{his_id[k]}:  current {rel_c[k]:8.2f} s   history {rel_h[k]:8.2f} s")
    if len(rows) > 5:
        print(f"  ... ({len(rows)} edges, current {rel_c.min():.2f}-{rel_c.max():.2f} s, "
              f"history {rel_h.min():.2f}-{rel_h.max():.2f} s)")
    print()

    hi = nearest_idx(t_gt, hist_t)
    ci = nearest_idx(t_gt, curr_t)
    ok = (np.abs(t_gt[hi] - hist_t) <= args.t_max_diff) & (np.abs(t_gt[ci] - curr_t) <= args.t_max_diff)
    if not ok.any():
        sys.exit("No edge matches GT in time - check --t_offset")

    d = np.linalg.norm(xy[hi] - xy[ci], axis=1)
    tp = ok & (d < args.dist)
    fp = ok & ~tp

    # GT revisits (needed for recall)
    gt_loop = gt_loop_indices(gt, t_gt, args.dist, args.min_dt)

    m = compute_metrics(tp, fp, hi, ci, gt_loop)
    name = args.name or os.path.splitext(os.path.basename(args.edges_csv))[0]

    print(f"Method:            {name}")
    print(f"Edges:             {len(rows)} (matched to GT in time: {int(ok.sum())})")
    print(f"TP edges: {m['tp']}   FP edges: {m['fp']}")
    print(f"GT revisit scans:  {m['gt_revisit_scans']}   detected (TP): {m['tp_scans']}   missed (FN): {m['fn_scans']}")
    print(f"Precision: {m['precision']:.4f}")
    print(f"Recall:    {m['recall']:.4f}")
    print(f"F-score:   {m['fscore']:.4f}")

    if args.csv:
        write_csv(args.csv, {
            "method": name,
            "edges_total": len(rows),
            "edges_matched": int(ok.sum()),
            **m,
            "dist": args.dist,
            "min_dt": args.min_dt,
            "t_offset": args.t_offset,
        })
        print(f"Metrics appended to: {args.csv}")

    title = (f"{name}   TP: {m['tp']}   FP: {m['fp']}   "
             f"P: {m['precision']:.2f}   R: {m['recall']:.2f}   F1: {m['fscore']:.2f}\n"
             f"(dist < {args.dist} m, GT revisit scans detected: "
             f"{m['tp_scans']}/{m['gt_revisit_scans']})")

    draw_gt = gt_loop if not args.no_gt_loops else np.array([], dtype=int)

    legend = [
        Line2D([], [], color="tab:blue", lw=1, label="GT trajectory"),
        Line2D([], [], color="tab:green", lw=2, label=f"TP ({m['tp']})"),
        Line2D([], [], color="red", lw=2, label=f"FP ({m['fp']})"),
    ]
    if len(draw_gt):
        legend.append(Line2D([], [], color="0.6", marker="o", ls="", ms=4,
                             label="GT revisit (expected loop)"))

    if args.time_z:
        fig = plt.figure(figsize=(11, 9))
        ax = fig.add_subplot(projection="3d")
        ax.plot(xy[:, 0], xy[:, 1], tt, color="tab:blue", lw=1)
        if len(draw_gt):
            ax.scatter(xy[draw_gt, 0], xy[draw_gt, 1], tt[draw_gt], s=3, c="0.6", alpha=0.5)
        for k in np.where(ok)[0]:
            c = "tab:green" if tp[k] else "red"
            ax.plot([xy[hi[k], 0], xy[ci[k], 0]], [xy[hi[k], 1], xy[ci[k], 1]],
                    [tt[hi[k]], tt[ci[k]]], color=c, lw=2)
            if args.labels:
                ax.text(xy[ci[k], 0], xy[ci[k], 1], tt[ci[k]], f"{cur_id[k]}-{his_id[k]}", fontsize=7)
        ax.set_zlabel("time [s]")
    else:
        fig, ax = plt.subplots(figsize=(11, 11))
        ax.plot(xy[:, 0], xy[:, 1], color="tab:blue", lw=1, zorder=1)
        if len(draw_gt):
            ax.scatter(xy[draw_gt, 0], xy[draw_gt, 1], s=6, c="0.6", alpha=0.5, zorder=2)

        for mask, c in ((tp, "tab:green"), (fp, "red")):
            idx = np.where(mask)[0]
            if len(idx):
                segs = np.stack([xy[hi[idx]], xy[ci[idx]]], axis=1)
                ax.add_collection(LineCollection(segs, colors=c, linewidths=2, zorder=3))
                ax.scatter(xy[ci[idx], 0], xy[ci[idx], 1], s=40, c=c, marker="o",
                           edgecolors="k", zorder=4)
                ax.scatter(xy[hi[idx], 0], xy[hi[idx], 1], s=40, c=c, marker="s",
                           edgecolors="k", zorder=4)
        if args.labels:
            for k in np.where(ok)[0]:
                ax.annotate(f"{cur_id[k]}-{his_id[k]}", xy[ci[k]], fontsize=7,
                            xytext=(4, 4), textcoords="offset points")
        ax.plot(*xy[0], "k^", ms=10, zorder=5)
        legend.append(Line2D([], [], color="k", marker="^", ls="", ms=8, label="start"))
        legend.append(Line2D([], [], color="0.3", marker="o", ls="", ms=6, label="current scan"))
        legend.append(Line2D([], [], color="0.3", marker="s", ls="", ms=6, label="history scan"))
        ax.set_aspect("equal")
        ax.grid(True, alpha=0.3)

    ax.set_xlabel("x [m]")
    ax.set_ylabel("y [m]")
    ax.set_title(title)
    ax.legend(handles=legend, loc="best")

    for k in np.where(fp)[0]:
        print(f"FP: {cur_id[k]} -> {his_id[k]}   GT dist {d[k]:.1f} m")

    if args.save:
        fig.savefig(args.save, dpi=150, bbox_inches="tight")
        print(f"Saved: {args.save}")
    if not args.no_show:
        plt.show()


if __name__ == "__main__":
    main()