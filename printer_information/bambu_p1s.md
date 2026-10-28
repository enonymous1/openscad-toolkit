# Bambu Lab P1S — Quick Reference and OpenSCAD Best Practices

A general, practical reference for modeling in OpenSCAD and preparing
prints for a Bambu Lab P1S. Verify any hardware-specific value against
your own printer and Bambu Lab's official documentation before relying
on it for a critical print. Bambu Lab's manuals are not redistributed
here; consult the Quick Start Guide and Technical Specifications that
shipped with the printer, or Bambu Lab's official P1S support pages.

## Overview

- **Printer:** Bambu Lab P1S, single-extruder desktop FDM printer
- **Common nozzle:** 0.4 mm (swappable; check your exact machine)
- **Build volume:** 256 × 256 × 256 mm
- **Slicer:** Bambu Studio is the manufacturer-recommended slicer.
  Other slicers can be used with a custom profile, but the starting
  values below assume Bambu Studio.

## Official specifications

From the manufacturer's published specifications for the P1S:

- **Build volume:** 256 × 256 × 256 mm (W × D × H)
- **Nozzle (included):** 0.4 mm; **optional nozzles:** 0.2 mm,
  0.6 mm, 0.8 mm
- **Filament diameter:** 1.75 mm
- **Max hotend temperature:** 300 °C
- **Max build plate temperature:** 100 °C
- **Included build plate:** Bambu Dual-Sided Textured PEI Plate
  (optional: Cool Plate, Engineering Plate, High Temperature Plate)
- **Max toolhead speed:** 500 mm/s; **max acceleration:** 20 m/s²
- **Supported materials:** PLA, PETG, TPU, ABS, ASA, PVA, PET
  (PA and PC are listed as capable). Carbon/glass-fiber reinforced
  filaments are **not recommended** without special handling.
- **Onboard features:** filament run-out sensor, optional filament
  odometry with AMS, chamber camera (timelapse support), activated
  carbon air filter, power-loss recovery
- **Connectivity:** Wi-Fi, Bluetooth, Bambu Bus; Bambu Studio
  (macOS/Windows)

AMS note: the Quick Start Guide recommends using Bambu Filament with
the AMS and avoiding very soft or damp filaments (such as TPU and
damp PVA), which can jam. See the official guide for AMS maintenance
guidance.

## OpenSCAD tips (design for reliable printing)

- **Units:** design in millimeters. OpenSCAD values are unitless, but
  1 unit = 1 mm is the standard. Confirm the scale in the slicer
  after every export.
- **Render before export:** use F6 (Render) before exporting an STL.
  Preview (F5) uses approximations; F6 produces the exact mesh.
- **Export format:** export STL (binary STL is this repo's default)
  and double-check scale and units in the slicer.
- **Circle resolution:** use `$fn` (or `cylinder($fn = ...)`) to
  control polygon resolution for circular features: higher for
  visible curves, lower for speed. For example,
  `cylinder(h = 5, r = 10, $fn = 64)` gives smooth curves.
- **Wall thickness:** make wall thickness a multiple of nozzle width
  (0.4 mm nozzle → 0.8 mm or 1.2 mm walls for 2 or 3 perimeters).
  Avoid single-wall prints unless intentionally designed and
  supported in the slicer.
- **Thin features:** keep printable features at least the nozzle
  diameter wide; fragile features need designed reinforcement or
  extra thickness.
- **Fillets and chamfers:** small fillets and chamfers reduce stress
  concentrations and improve printability.
- **Orientation:** design so load-bearing features align with layer
  orientation for strength, and give the part a flat face for bed
  adhesion.
- **Manifold geometry:** keep models manifold — no zero-thickness
  faces, no non-manifold edges. Use `minkowski()` cautiously: it can
  massively increase mesh complexity. When two solids must join,
  overlap them slightly instead of letting them touch at exactly one
  face; coincident faces are a common source of slicer complaints.
- **Fitting assemblies:** export mating parts separately and design
  in tolerances. A starting point is 0.2–0.4 mm of clearance for
  friction fits; test and adjust per filament. This repo's tolerance
  test exists for exactly that.
- **Small details:** emboss or deboss text and fine details at least
  0.6 mm deep/high, and avoid hairline strokes.

## Recommended slicer and printer settings (starting points)

These are starting suggestions. Always calibrate and tune per filament
and environment, and never exceed the printer's maximum temperatures.

- **Nozzle diameter:** 0.4 mm (adjust layer heights and wall counts
  accordingly)
- **Layer height:** fine 0.12 mm, standard 0.16–0.20 mm,
  draft 0.24–0.28 mm
- **Perimeters / walls:** 2–4 (wall thickness a multiple of nozzle width)
- **Top solid layers:** 4–6
- **Infill:** 10–25% for general parts; more for load-bearing parts
- **First layer speed:** 15–25 mm/s for best adhesion
- **Print speed (perimeter / infill):** 40–60 mm/s (slower for fine details)
- **Travel speed:** 150–250 mm/s (depends on firmware and mechanics)
- **Retraction:** 0.8–1.2 mm starting range for direct drive; tune to
  minimize stringing
- **Cooling fan:** PLA 100% after the first few layers, PETG 20–60%,
  ABS low fan (enclosure recommended)
- **Bed temperature:** PLA 50–70 °C, PETG 70–85 °C,
  ABS 90–100 °C (enclosure recommended; 100 °C is the bed maximum)
- **Printing temperature (typical ranges):** PLA 190–220 °C,
  PETG 230–250 °C, ABS 230–260 °C
- **Supports:** as needed; tree supports or standard supports
  depending on the part. Add a brim or raft for small or warpy parts.
- **Bridging:** reduce print speed and increase cooling for better bridges.

## Calibration and tuning checklist

- Calibrate flow in Bambu Studio (flow rate and flow-dynamics /
  pressure-advance calibration) and check it with the 20 mm
  calibration cube in this repo. The P1S does not expose Marlin-style
  E-steps or PID menus; calibrate through Bambu Studio and
  per-filament profiles instead.
- Measure filament diameter at several points and enter the mean in
  the slicer.
- Print a temperature tower for each filament to find the best layer
  adhesion versus detail.
- Tune retraction to minimize oozing and stringing without
  under-extruding at the start of moves.

## Troubleshooting

- **Warping:** increase bed temperature, use a brim or raft, check bed
  adhesion (PEI plate, glue stick), or use an enclosure for ABS/PETG.
- **Stringing:** increase retraction, reduce print temperature, enable
  coasting/wipe if supported.
- **Poor layer adhesion:** increase temperature, slow print speed,
  check filament moisture and extrusion multiplier.
- **Blobs / z-seam issues:** use seam alignment settings, enable
  coasting or wipe, tune acceleration.
- **Dimensional inaccuracy:** check flow calibration and compensate
  in the model tolerances.

## OpenSCAD to slicer workflow

1. Model in millimeters, with clear tolerances for fits.
2. Render with F6 in OpenSCAD.
3. Export STL and verify scale and units in the slicer.
4. Apply the official Bambu Studio profile for the P1S, or a
   calibrated custom profile (see `profiles/`).
5. Run a small test print to validate fit and clearance.

## Bambu-specific notes

- Start from the official Bambu Studio profile for the P1S when one is
  available, then fine-tune.
- With the AMS (multi-material system), configure purge towers and
  tool changes carefully and allow extra time for purges.
- Keep firmware and slicer software up to date for reliability and
  new features.

## Included examples and export script

- `openscad_scripts/examples/calibration_cube.scad` — 20 × 20 × 20 mm
  solid cube for dimensional checks and flow calibration.
- `openscad_scripts/examples/tolerance_test.scad` — hole plate and
  pin strip with a range of clearances to test friction fits.
- `openscad_scripts/examples/temperature_tower.scad` — stacked
  sections with embossed temperature labels to evaluate layer quality
  at different temperatures.
- `scripts/export_stl.ps1` (Windows) / `scripts/export_stl.sh`
  (Linux/macOS) — render the models to `openscad_scripts/stls/`
  using the OpenSCAD CLI, then verify the STLs.

## Starter Bambu profile

A starter profile reference is included as
`profiles/bambu_p1s_profile.sample.json`; `profiles/README.md`
explains how to apply its values in Bambu Studio. It is a mapping
reference, not an importable Bambu Studio profile. Fine-tune per
filament and test prints.
