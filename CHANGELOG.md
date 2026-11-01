# Changelog

## 2.0.2 — 2026-11-01

No model or geometry changes. Staff-review step 2:

- Export scripts no longer leave a stale STL after a failed render:
  previously generated outputs are cleared up front, and each target
  file is deleted again before its render, in both
  `scripts/export_stl.sh` and `scripts/export_stl.ps1`, and both
  script headers now state that behavior honestly.
- `scripts/export_stl.sh`: validates a user-supplied `$OPENSCAD`
  path (errors out if it is set but not executable, instead of
  failing confusingly inside the first render), accepts an optional
  `--skip-check` flag, and now errors out when python3 is missing
  instead of warning and exiting 0 with unverified STLs.
- Rewrote `README.md` with Description, Prerequisites, Installation,
  Local Development, and Deployment sections, checker-verified
  bounding boxes in the models table (temperature tower 31.6 mm deep,
  tolerance plate 6.6 mm tall, pin strip 9 mm overall), and HTML
  comments marking where each planned visual asset goes (no broken
  image links until the assets exist).

## 2.0.1 — 2026-11-01

No model or geometry changes. Staff-review step 1 only:

- `scripts/check_stl.py`: added docstrings for `read_triangles`,
  `check_file`, and `main`, stating each function's contract. A
  malformed ASCII STL now reports `FAIL ...: unparseable` instead of
  dying with a `ValueError` traceback.
- Added `tests/test_check_stl.py` (standard library `unittest` only,
  no OpenSCAD needed): valid binary and ASCII files pass; open mesh,
  wrong bounding box, malformed ASCII, garbage, missing, and empty
  files all fail with the expected message. Run with
  `python3 -m unittest discover tests -v` from the repo root.

## 2.0.0 — 2026-10-28

Standalone modernization of the 2026-07-19 original. The original
history is not carried over (see the README for why); this is a fresh
single-commit export under the public identity.

- Fixed `tolerance_test.scad`: pins and holes are no longer
  double-translated off the plate, and clearance is now diametral play
  (hole diameter = pin diameter + clearance), so larger clearance is
  looser. The test is now a hole plate plus a separate pin strip that
  flips face-down onto it, with the clearance embossed on each part.
- Fixed `temperature_tower.scad`: labels are rotated onto the front
  face and protrude 0.8 mm, instead of extruding upward inside the
  blocks. Removed the dead `children()` call.
- Fixed `zendrive_u9m_box.scad`: the lid text is now a visible
  engraving in the top face (the full-footprint pad that covered it is
  gone), the divider sits in the wall between the drive and cable
  cavities, an `Assembled` preview shows the lid seated in its groove,
  and asserts check the fit and the 256 mm build volume. Drive and
  cable dimensions are unchanged.
- Export scripts now fail on a failed render, render the ZenDrive box
  and lid as separate STLs, export binary STL, and run
  `scripts/check_stl.py`, which verifies each STL's bounding box and
  that its mesh is closed. Added a Linux/macOS export script and a CI
  workflow that renders and checks every model.
- Removed the redistributed Bambu Lab PDFs and their garbled text
  extracts, and the duplicated printer reference (one canonical copy
  remains). Added a real MIT LICENSE, `.gitattributes` (LF endings),
  and a cleaned-up `.gitignore` that excludes generated STLs.

## 1.0.0 — 2026-07-19

Original version: OpenSCAD calibration examples, the ZenDrive U9M box,
Bambu P1S documentation and profiles, and a PowerShell export script.
