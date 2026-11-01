#!/usr/bin/env bash
# Render every OpenSCAD model in this repo to binary STL.
#
# Usage: ./scripts/export_stl.sh [out-dir] [--skip-check]
#   out-dir defaults to openscad_scripts/stls under the repo root.
#   --skip-check accepts STLs without running check_stl.py; without
#   it, a missing python3 is an error, not a warning.
#
# The ZenDrive "Both" and "Assembled" previews are not exported: a
# single STL holding two separate solids is confusing to slice, so Box
# and Lid are exported separately with the part selected via -D.
# Each target STL is deleted before its render, so a failed run never
# leaves a previous STL in place to be sliced by mistake.
#
# Requires OpenSCAD 2021.01 (or a newer nightly) on PATH, or set the
# OPENSCAD environment variable to its path. If python3 is available,
# scripts/check_stl.py is run afterwards to verify each STL's
# bounding box and closed mesh.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKIP_CHECK=0
OUT_DIR=""
for arg in "$@"; do
    case "$arg" in
        --skip-check) SKIP_CHECK=1 ;;
        *)
            if [ -z "$OUT_DIR" ]; then
                OUT_DIR="$arg"
            else
                echo "error: unexpected argument: $arg" >&2
                exit 1
            fi
            ;;
    esac
done
OUT_DIR="${OUT_DIR:-$REPO_ROOT/openscad_scripts/stls}"

if [ -n "${OPENSCAD:-}" ] && [ ! -x "$OPENSCAD" ]; then
    echo "error: OPENSCAD is set but not executable: $OPENSCAD" >&2
    exit 1
fi
OPENSCAD_BIN="${OPENSCAD:-$(command -v openscad || true)}"

if [ -z "$OPENSCAD_BIN" ]; then
    echo "error: OpenSCAD not found. Install OpenSCAD 2021.01, add it to PATH, or set OPENSCAD." >&2
    exit 1
fi

mkdir -p "$OUT_DIR"

# Clear previously generated outputs up front: deleting each target
# only as it is rendered would still leave stale files for models
# never reached after an early failure.
for stale in calibration_cube.stl temperature_tower.stl tolerance_test-plate.stl tolerance_test-pins.stl zendrive_u9m_box-box.stl zendrive_u9m_box-lid.stl; do
    rm -f "$OUT_DIR/$stale"
done

render() {
    local source="$1" output="$2" define="${3:-}"
    echo "Rendering $source -> $output"
    # Delete any previous output first: a failed render must never
    # leave yesterday's STL in place to be sliced by mistake.
    rm -f "$output"
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

if [ "$SKIP_CHECK" -eq 1 ]; then
    echo "warning: STL bounding-box checks skipped (--skip-check). STLs are unverified." >&2
elif command -v python3 >/dev/null 2>&1 && [ -f "$REPO_ROOT/scripts/check_stl.py" ]; then
    echo "Checking STLs with check_stl.py..."
    python3 "$REPO_ROOT/scripts/check_stl.py" "$OUT_DIR"
else
    echo "error: python3 not found; STL checks were skipped. Install python3 and re-run, or pass --skip-check to accept unverified STLs." >&2
    exit 1
fi
