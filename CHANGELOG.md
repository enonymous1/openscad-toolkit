# Changelog

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
