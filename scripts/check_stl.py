#!/usr/bin/env python3
"""Verify the STLs produced by scripts/export_stl.ps1 / export_stl.sh.

Checks, per file: the file exists and is non-empty, it parses as STL
(binary or ASCII), its bounding box matches the expected dimensions
for that model within 0.1 mm, and its mesh is closed (every undirected
edge is shared by exactly two triangles). A closed mesh is what a
slicer needs; the bounding-box check is what catches a part rendered
with the wrong part selector, a doubled translation, or a label
buried inside its block.

Usage: python3 scripts/check_stl.py [stl-dir]
The directory defaults to openscad_scripts/stls under the repo root.
Standard library only.
"""

from __future__ import annotations

import struct
import sys
from collections import Counter
from pathlib import Path

TOLERANCE_MM = 0.1

# (min_x, min_y, min_z), (max_x, max_y, max_z), in millimetres.
EXPECTED = {
    "calibration_cube.stl": ((-10.0, -10.0, -10.0), (10.0, 10.0, 10.0)),
    "temperature_tower.stl": ((-15.0, -15.8, 0.0), (15.0, 15.0, 70.0)),
    "tolerance_test-plate.stl": ((-60.0, -15.0, -3.0), (60.0, 15.0, 3.6)),
    "tolerance_test-pins.stl": ((-60.0, -8.0, -1.5), (60.0, 8.0, 7.5)),
    "zendrive_u9m_box-box.stl": ((0.0, 0.0, 0.0), (150.5, 174.5, 21.4)),
    "zendrive_u9m_box-lid.stl": ((0.0, 0.0, 0.0), (150.5, 171.1, 4.0)),
}


def read_triangles(path: Path) -> list[tuple[tuple[float, float, float], ...]]:
    data = path.read_bytes()
    if len(data) >= 84:
        count = struct.unpack("<I", data[80:84])[0]
        if count > 0 and len(data) == 84 + count * 50:
            triangles = []
            for i in range(count):
                vals = struct.unpack("<12fH", data[84 + i * 50 : 84 + (i + 1) * 50])
                triangles.append(
                    (
                        (vals[3], vals[4], vals[5]),
                        (vals[6], vals[7], vals[8]),
                        (vals[9], vals[10], vals[11]),
                    )
                )
            return triangles
    # ASCII STL fallback.
    triangles: list[tuple[tuple[float, float, float], ...]] = []
    current: list[tuple[float, float, float]] = []
    for line in data.decode("utf-8", "replace").splitlines():
        parts = line.split()
        if len(parts) == 4 and parts[0] == "vertex":
            current.append((float(parts[1]), float(parts[2]), float(parts[3])))
            if len(current) == 3:
                triangles.append(tuple(current))
                current = []
    return triangles


def check_file(path: Path, expected_min, expected_max) -> list[str]:
    errors: list[str] = []
    if not path.is_file():
        return [f"missing: {path.name}"]
    if path.stat().st_size == 0:
        return [f"empty: {path.name}"]
    triangles = read_triangles(path)
    if not triangles:
        return [f"no triangles parsed: {path.name}"]
    vertices = [v for tri in triangles for v in tri]
    actual_min = tuple(min(v[i] for v in vertices) for i in range(3))
    actual_max = tuple(max(v[i] for v in vertices) for i in range(3))
    for axis, (actual, expected) in enumerate(zip(actual_min, expected_min)):
        if abs(actual - expected) > TOLERANCE_MM:
            errors.append(
                f"{path.name}: bbox min axis {axis} is {actual}, expected {expected}"
            )
    for axis, (actual, expected) in enumerate(zip(actual_max, expected_max)):
        if abs(actual - expected) > TOLERANCE_MM:
            errors.append(
                f"{path.name}: bbox max axis {axis} is {actual}, expected {expected}"
            )
    edges: Counter[frozenset[tuple[float, float, float]]] = Counter()
    for tri in triangles:
        keyed = [tuple(round(c, 4) for c in v) for v in tri]
        for a, b in ((0, 1), (1, 2), (2, 0)):
            edges[frozenset((keyed[a], keyed[b]))] += 1
    bad = [count for count in edges.values() if count != 2]
    if bad:
        errors.append(
            f"{path.name}: mesh is not closed: {len(bad)} of {len(edges)} edges "
            f"are shared by != 2 triangles"
        )
    if not errors:
        print(
            f"PASS {path.name}: {len(triangles)} triangles, "
            f"bbox {tuple(round(v, 2) for v in actual_min)}.."
            f"{tuple(round(v, 2) for v in actual_max)}"
        )
    return errors


def main(argv: list[str]) -> int:
    stl_dir = Path(argv[1]) if len(argv) > 1 else (
        Path(__file__).resolve().parent.parent / "openscad_scripts" / "stls"
    )
    errors: list[str] = []
    for name, (expected_min, expected_max) in EXPECTED.items():
        errors.extend(check_file(stl_dir / name, expected_min, expected_max))
    for error in errors:
        print(f"FAIL {error}", file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
