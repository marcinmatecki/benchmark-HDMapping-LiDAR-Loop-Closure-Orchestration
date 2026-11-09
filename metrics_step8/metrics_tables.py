#!/usr/bin/env python3
"""
Step 8: Converts CSV files from pointcloud_metrics into Markdown and LaTeX tables (all rows included, no averaging).
"""

import csv
import os

DATA_DIR = os.path.expanduser("~/hdmapping-benchmark-loop-closure/data/tum")

ALGORITHMS = [
    ("optimized-sc-f-loam-loop.csv", "Optimized-SC-F-LOAM"),
    ("pin-slam-loop.csv", "PIN-SLAM"),
]

HEADER = [
    "Scan", "Submap", "CD", "CD PC1-PC2", "CD PC2-PC1",
    "Hausdorff", "RMSE", "Precision", "Recall", "F-score",
]


def tex(s):
    return s.replace("\\", "\\textbackslash{}").replace("_", "\\_").replace("%", "\\%").replace("&", "\\&")


tables = []

for csv_name, name in ALGORITHMS:
    path = os.path.join(DATA_DIR, csv_name)

    if not os.path.isfile(path):
        print(f"Brak pliku: {path}")
        continue

    with open(path, encoding="utf-8") as f:
        reader = csv.reader(f)
        next(reader, None)  
        rows = [row for row in reader if row]

    tables.append((csv_name, name, rows))


# ============================================================
# Markdown
# ============================================================

md_file = os.path.join(DATA_DIR, "pointcloud_metrics_results.md")

with open(md_file, "w") as f:

    f.write("# point cloud metrics benchmark\n\n")

    for csv_name, name, rows in tables:

        f.write(f"## {name}\n\n")

        f.write("| " + " | ".join(HEADER) + " |\n")
        f.write("|" + "---|" * len(HEADER) + "\n")

        for row in rows:
            f.write("| " + " | ".join(row) + " |\n")

        f.write("\n")

print(f"Saved: {md_file}")


# ============================================================
# LaTeX
# ============================================================

latex_file = os.path.join(DATA_DIR, "pointcloud_metrics_results.tex")

latex = ""

for csv_name, name, rows in tables:

    caption = f"Point cloud metrics: {name}."
    table_label = "tab:pc_metrics_" + name.lower().replace("-", "_")

    latex += f"""\\begin{{table}}[]
\\centering
\\resizebox{{\\textwidth}}{{!}}{{%
\\begin{{tabular}}{{ll{"c" * (len(HEADER) - 2)}}}
\\rowcolor[HTML]{{C0C0C0}}
{" & ".join(HEADER)} \\\\
"""

    for row in rows:
        latex += " & ".join(tex(c) for c in row) + " \\\\\n"

    latex += f"""\\end{{tabular}}}}
\\caption{{{caption}}}
\\label{{{table_label}}}
\\end{{table}}

"""

with open(latex_file, "w") as f:
    f.write(latex)

print(f"Saved: {latex_file}")