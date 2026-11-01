# Changelog

## 2.0.5 — 2026-11-01

No geometry or script changes. Staff-review step 5 (visual assets
V1, V5, V2):

- `docs/assets/hero-assembled.png` (1200 × 900, 29 KB): the ZenDrive
  box in Assembled view, lid seated in the groove, engraving, grip,
  and finger notch visible. Wired into the README directly after the
  Description.
- `docs/assets/calibration-trio.png` (1800 × 600, 86 KB): calibration
  cube, temperature tower (all seven labels 190–220 legible), and
  tolerance test in Both preview, composited from three preview
  renders at the same camera angle. Wired into the README at the top
  of the Models section.
- `docs/assets/README.md` documents how both images were captured
  (OpenSCAD 2021.01 preview mode under `xvfb-run`, camera settings,
  Pillow compositing) so they can be re-captured after a model
  change. Preview mode is used deliberately: a full `--render`
  export recolors everything to OpenSCAD's default gold, while
  preview keeps the file's dark-box / light-lid colors.
- V5 (the Mermaid pipeline diagram) was already in the README since
  the 2.0.2 rewrite, so this step confirms it rather than adding it.
  V3 (tolerance close-up), V4 (lid cross-section), and V6 (terminal
  demo GIF) remain planned, not captured — and no printed-part
  photograph belongs in `docs/assets/` until a real print exists.

## 2.0.4 — 2026-11-01

No geometry changes. Staff-review step 4 (single render manifest):

- Added `models.json` at the repo root: one entry per model, one
  output per STL, with an optional `define` part selector. Both
  export scripts now render exactly what the manifest lists, and
  stale-output clearing in both scripts also comes from the manifest
  — there is no longer a hardcoded render list in either script.
- `scripts/check_stl.py` cross-checks the manifest against its
  `EXPECTED` table and fails on a mismatch, a duplicate manifest
  output, or an unreadable manifest, so a model added to one list
  and not the other is caught instead of silently unchecked.
- Added `tests/test_manifest.py`: manifest non-empty, output files
  unique, sources exist, defines are part selectors, and manifest
  files exactly equal `check_stl.EXPECTED`. CI now validates
  `models.json` and runs the full unit-test suite before rendering.
- Trade-off, stated plainly: the shell export now requires python3
  to read the manifest (the shell has no JSON parser). Python was
  already required for any verified run; `--skip-check` now skips
  verification only, not manifest parsing. The PowerShell export
  reads the manifest natively with `ConvertFrom-Json`, so on Windows
  Python is still only needed for verification.

## 2.0.3 — 2026-11-01

Geometry change — STLs rendered from earlier versions are superseded.
Staff-review step 3 (ZenDrive constants and asserts):

- Named the previously inline ZenDrive constants: `divider_t` (1.5),
  `join_overlap` (0.2), `cut_overshoot` (0.1), `lid_recess` (1.0),
  `divider_clearance` (0.2), and `divider_overlap` (0.5), with
  comments stating why each exists. The groove cut
  (`floor_thickness + lid_recess + cut_overshoot`) and the lid handle
  overlap are numerically unchanged.
- Fixed the cable-side wall (review finding F5): `inner_w` is now
  derived from the actual cavity layout
  (`drive_w + 2·clearance + divider_t + cable_slot_w`) instead of
  `clearance * 3`, which had made it 0.5 mm short. Box outer width
  174.5 → 175.0 mm, lid width 171.1 → 171.6 mm, and the cable-side
  wall is now a full 3.0 mm like the other walls. Checker expectations
  and the README table were updated to match.
- Fixed the divider/lid interference (review finding F6): the divider
  now stops `divider_clearance` (0.2 mm) below the lid-groove floor
  (divider top 18.9 → 17.7 mm, groove floor 17.9 mm) instead of poking
  1 mm into the groove channel, because the groove floor is the
  sliding datum. No other ZenDrive dimension changed.
- New asserts: divider thickness sane, cable cavity ends at or before
  the inner wall, divider top stays below the groove floor, and
  divider height positive.
- Unknown `part_to_render` values now fail with an assert in both
  `zendrive_u9m_box.scad` and `tolerance_test.scad`, instead of
  silently falling through to the Both preview and rendering the
  wrong part. Valid values are unchanged.

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
