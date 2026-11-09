import os
import numpy as np
from scipy.spatial.transform import Rotation

sessions = [
    "/data/tum/output_hdmapping-PIN-SLAM_trajectory_tum.txt",
    "/data/tum/output_hdmapping-optimized-sc-f-loam_trajectory_tum.txt",
]

for input_file in sessions:
    if not os.path.isfile(input_file):
        print(f"Nie znaleziono pliku: {input_file}")
        continue

    base, ext = os.path.splitext(input_file)
    output_file = base + "-local-zero.txt"

    data = np.loadtxt(input_file, ndmin=2)

    if data.shape[1] != 8 or data.shape[0] == 0:
        print(f"Nieprawidłowy format: {input_file}")
        continue

    timestamps = data[:, 0]
    translations = data[:, 1:4]
    quaternions = data[:, 4:8]

    duplicates = np.count_nonzero(np.diff(timestamps) == 0)
    print(f"{input_file}: rows={len(data)}, repeated consecutive timestamps=={duplicates}")

    rotations = Rotation.from_quat(quaternions)

    R0 = rotations[0]
    t0 = translations[0]

    local_translations = R0.inv().apply(translations - t0)
    local_rotations = R0.inv() * rotations

    local_timestamps = timestamps - timestamps[0]

    output = np.column_stack([
        local_timestamps,
        local_translations,
        local_rotations.as_quat()
    ])

    np.savetxt(output_file, output, fmt="%.15f")

    print(f"Input:  {input_file}")
    print(f"Output: {output_file}")