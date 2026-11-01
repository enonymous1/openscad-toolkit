#!/usr/bin/env bash
# Render every OpenSCAD model in this repo to binary STL.
#
# Usage: ./scripts/export_stl.sh [out-dir] [--skip-check]
#   out-dir defaults to openscad_scripts/stls under the repo root.
#   --skip-check accepts STLs without running check_stl.py. It does
#   not remove the python3 requirement: python3 is still needed to
#   read models.json (see below).
#
# The render list comes from models.json at the repo root: one entry
# per model, with one output file (and an optional -D part selector)
# per STL. Both export scripts and the checker read the same file,
# so adding a model means editing the manifest, not the scripts.
# The ZenDrive "Both" and "Assembled" previews are not exported: a
# single STL holding two separate solids is confusing to slice, so Box
# and Lid are exported separately with the part selected via -D.
# Each target STL is deleted before its render, so a failed run never
# leaves a previous STL in place to be sliced by mistake.
#
# Requires OpenSCAD 2021.01 (or a newer nightly) on PATH, or set the
# OPENSCAD environment variable to its path. Requires python3 as well:
# this script uses it to read models.json (the shell has no JSON
# parser) and, unless --skip-check is passed, to run
# scripts/check_stl.py afterwards to verify each STL's bounding box
# and closed mesh.
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

if ! command -v python3 >/dev/null 2>&1; then
    echo "error: python3 is required to read models.json." >&2
    exit 1
fi
if [ ! -f "$REPO_ROOT/models.json" ]; then
    echo "error: models.json not found at $REPO_ROOT/models.json" >&2
    exit 1
fi

# Print one render per line from models.json: source, output file,
# and -D define (empty when the model has no part selector), tab
# separated. The define values contain no tabs, so this is safe.
# Read once into RENDERS so a manifest parse failure is caught here
# instead of silently producing no renders (a failure inside a
# process substitution would not stop the script under set -e).
manifest_renders() {
    python3 - "$REPO_ROOT/models.json" <<'PY'
import json, sys
with open(sys.argv[1], encoding="utf-8") as f:
    manifest = json.load(f)
for model in manifest["models"]:
    for output in model["outputs"]:
        print(f'{model["source"]}\t{output["file"]}\t{output.get("define", "")}')
PY
}

if ! RENDERS="$(manifest_renders)"; then
    echo "error: failed to read models.json" >&2
    exit 1
fi
if [ -z "$RENDERS" ]; then
    echo "error: models.json contains no renders" >&2
    exit 1
fi

mkdir -p "$OUT_DIR"

# Clear previously generated outputs up front: deleting each target
# only as it is rendered would still leave stale files for models
# never reached after an early failure.
while IFS=$'\t' read -r _source _file _define; do
    [ -n "$_file" ] && rm -f "$OUT_DIR/$_file"
done <<< "$RENDERS"

render() {
    local source="$1" output="$2" define="${3:-}"
    if [ ! -f "$REPO_ROOT/$source" ]; then
        echo "error: source not found: $REPO_ROOT/$source" >&2
        exit 1
    fi
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

while IFS=$'\t' read -r source file define; do
    [ -n "$source" ] || continue
    render "$source" "$OUT_DIR/$file" "$define"
done <<< "$RENDERS"

echo "Done. STLs are in $OUT_DIR."

if [ "$SKIP_CHECK" -eq 1 ]; then
    echo "warning: STL bounding-box checks skipped (--skip-check). STLs are unverified." >&2
elif [ ! -f "$REPO_ROOT/scripts/check_stl.py" ]; then
    echo "error: scripts/check_stl.py not found." >&2
    exit 1
else
    echo "Checking STLs with check_stl.py..."
    python3 "$REPO_ROOT/scripts/check_stl.py" "$OUT_DIR"
fi
