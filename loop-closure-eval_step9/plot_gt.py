#!/usr/bin/env python3
"""
Plot the ground-truth trajectory (TUM format) and save it as an image.

  blue  - GT trajectory
  gray  - GT revisits: poses where GT has a loop (dist < --dist, dt > --min_dt)

Usage:
  python3 plot_gt.py ground_truth.tum --save gt.png --no_show
  python3 plot_gt.py ground_truth.tum --no_gt_loops --save gt.pdf --no_show
  python3 plot_gt.py ground_truth.tum --time_z --save gt_3d.png --no_show
"""

import argparse

import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
from scipy.spatial import cKDTree


def gt_loop_indices(gt, t_gt, dist, min_dt):
    """Indices of GT poses that revisit a previously visited place."""
    pairs = cKDTree(gt[:, 1:4]).query_pairs(r=dist, output_type="ndarray")
    if not len(pairs):
        return np.array([], dtype=int)
    a = np.minimum(pairs[:, 0], pairs[:, 1])
    b = np.maximum(pairs[:, 0], pairs[:, 1])
    return np.unique(b[(t_gt[b] - t_gt[a]) > min_dt])


def main():
    ap = argparse.ArgumentParser(description="Plot a GT trajectory in TUM format.")
    ap.add_argument("gt_tum", help="GT trajectory in TUM format")
    ap.add_argument("--dist", type=float, default=5.0,
                    help="max distance [m] for a GT revisit (default 5.0)")
    ap.add_argument("--min_dt", type=float, default=30.0,
                    help="min time gap [s] for a GT revisit (default 30.0)")
    ap.add_argument("--no_gt_loops", action="store_true", help="do not draw gray GT revisits")
    ap.add_argument("--time_z", action="store_true", help="3D view, Z axis = time")
    ap.add_argument("--title", default=None, help="plot title (default: none)")
    ap.add_argument("--dpi", type=int, default=300, help="image resolution (default 300)")
    ap.add_argument("--save", help="output file (.png, .pdf, .svg)")
    ap.add_argument("--no_show", action="store_true", help="do not open plot window")
    args = ap.parse_args()

    if args.no_show:
        matplotlib.use("Agg")

    gt = np.loadtxt(args.gt_tum, comments="#")
    t_gt, xy = gt[:, 0], gt[:, 1:3]
    tt = t_gt - t_gt[0]

    seg = np.linalg.norm(np.diff(gt[:, 1:4], axis=0), axis=1)
    print(f"Poses:      {len(gt)}")
    print(f"Duration:   {tt[-1]:.1f} s")
    print(f"Length:     {seg.sum():.1f} m")
    print(f"Frequency:  {(len(gt) - 1) / tt[-1]:.2f} Hz")

    loops = np.array([], dtype=int)
    if not args.no_gt_loops:
        loops = gt_loop_indices(gt, t_gt, args.dist, args.min_dt)
        print(f"GT revisit poses: {len(loops)} (dist < {args.dist} m, dt > {args.min_dt} s)")

    legend = [Line2D([], [], color="tab:blue", lw=1.5, label="GT trajectory")]

    if args.time_z:
        fig = plt.figure(figsize=(9, 8))
        ax = fig.add_subplot(projection="3d")
        ax.plot(xy[:, 0], xy[:, 1], tt, color="tab:blue", lw=1.5)
        if len(loops):
            ax.scatter(xy[loops, 0], xy[loops, 1], tt[loops], s=4, c="0.5", alpha=0.6)
        ax.scatter(*xy[0], tt[0], c="k", marker="^", s=80)
        ax.scatter(*xy[-1], tt[-1], c="k", marker="s", s=60)
        ax.set_zlabel("time [s]")
    else:
        fig, ax = plt.subplots(figsize=(9, 9))
        ax.plot(xy[:, 0], xy[:, 1], color="tab:blue", lw=1.5, zorder=1)
        if len(loops):
            ax.scatter(xy[loops, 0], xy[loops, 1], s=8, c="0.5", alpha=0.6, zorder=2)
        ax.plot(*xy[0], "k^", ms=10, zorder=3)
        ax.plot(*xy[-1], "ks", ms=8, zorder=3)
        ax.set_aspect("equal")
        ax.grid(True, alpha=0.3)

    if len(loops):
        legend.append(Line2D([], [], color="0.5", marker="o", ls="", ms=5,
                             label="GT revisit (expected loop)"))
    legend.append(Line2D([], [], color="k", marker="^", ls="", ms=8, label="start"))
    legend.append(Line2D([], [], color="k", marker="s", ls="", ms=7, label="end"))

    ax.set_xlabel("x [m]")
    ax.set_ylabel("y [m]")
    if args.title:
        ax.set_title(args.title)
    ax.legend(handles=legend, loc="best")

    if args.save:
        fig.savefig(args.save, dpi=args.dpi, bbox_inches="tight")
        print(f"Saved: {args.save}")
    if not args.no_show:
        plt.show()


if __name__ == "__main__":
    main()