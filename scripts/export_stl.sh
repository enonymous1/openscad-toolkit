#!/usr/bin/env bash
# Render every OpenSCAD model in this repo to binary STL.
#
# Usage: ./scripts/export_stl.sh [out-dir]
#   out-dir defaults to openscad_scripts/stls under the repo root.
#
# The ZenDrive "Both" and "Assembled" previews are not exported: a
# single STL holding two separate solids is confusing to slice, so Box
# and Lid are exported separately with the part selected via -D.
# Any failed render stops the script (set -e) instead of leaving a
# stale STL behind.
#
# Requires OpenSCAD 2021.01 (or a newer nightly) on PATH, or set the
# OPENSCAD environment variable to its path. If python3 is available,
# scripts/check_stl.py is run afterwards to verify each STL's
# bounding box and closed mesh.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${1:-$REPO_ROOT/openscad_scripts/stls}"
OPENSCAD_BIN="${OPENSCAD:-$(command -v openscad || true)}"

if [ -z "$OPENSCAD_BIN" ]; then
    echo "error: OpenSCAD not found. Install OpenSCAD 2021.01, add it to PATH, or set OPENSCAD." >&2
    exit 1
fi

mkdir -p "$OUT_DIR"

render() {
    local source="$1" output="$2" define="${3:-}"
    echo "Rendering $source -> $output"
    if [ -n "$define" ]; then
        "$OPENSCAD_BIN" --render --export-format binstl -D "$define" -o "$output" "$REPO_ROOT/$source"
    else
        "$OPENSCAD_BIN" --render --export-format binstl -o "$output" "$REPO_ROOT/$source"
    fi
}

render "openscad_scripts/examples/calibration_cube.scad" "$OUT_DIR/calibration_cube.stl"
render "openscad_scripts/examples/temperature_tower.scad" "$OUT_DIR/temperature_tower.stl"
render "openscad_scripts/examples/tolerance_test.scad" "$OUT_DIR/tolerance_test-plate.stl" 'part_to_render="Plate"'
render "openscad_scripts/examples/tolerance_test.scad" "$OUT_DIR/tolerance_test-pins.stl" 'part_to_render="Pins"'
render "openscad_scripts/zendrive_u9m_box/zendrive_u9m_box.scad" "$OUT_DIR/zendrive_u9m_box-box.stl" 'part_to_render="Box"'
render "openscad_scripts/zendrive_u9m_box/zendrive_u9m_box.scad" "$OUT_DIR/zendrive_u9m_box-lid.stl" 'part_to_render="Lid"'

echo "Done. STLs are in $OUT_DIR."

if command -v python3 >/dev/null 2>&1 && [ -f "$REPO_ROOT/scripts/check_stl.py" ]; then
    echo "Checking STLs with check_stl.py..."
    python3 "$REPO_ROOT/scripts/check_stl.py" "$OUT_DIR"
else
    echo "warning: python3 not found; STL bounding-box checks were skipped. Run: python3 scripts/check_stl.py $OUT_DIR" >&2
fi
