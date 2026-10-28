# openscad-toolkit

Parametric OpenSCAD models, calibration prints, and render-and-verify
tooling for the Bambu Lab P1S.
Everything is designed in millimeters.

## What is in here

| Model | File | Rendered size |
| --- | --- | --- |
| Calibration cube, 20 × 20 × 20 mm | `openscad_scripts/examples/calibration_cube.scad` | 20 × 20 × 20 mm |
| Temperature tower, 190–220 °C sections with embossed labels | `openscad_scripts/examples/temperature_tower.scad` | 30 × 30 × 70 mm |
| Tolerance test: hole plate + pin strip, clearances −0.2 to +0.4 mm | `openscad_scripts/examples/tolerance_test.scad` | Plate 120 × 30 × 6 mm; strip 120 × 16 × 3 mm, pins 6 mm tall |
| ASUS ZenDrive U9M storage box with sliding lid | `openscad_scripts/zendrive_u9m_box/zendrive_u9m_box.scad` | Box 150.5 × 174.5 × 21.4 mm; lid 150.5 × 171.1 × 4 mm |

Also included: a Bambu P1S quick reference and OpenSCAD best
practices (`printer_information/bambu_p1s.md`), and a starter print
profile as a mapping reference (`profiles/bambu_p1s_profile.sample.json`,
not an importable Bambu Studio file — see `profiles/README.md`).

## Quick start

Prerequisites: [OpenSCAD](https://openscad.org/downloads.html)
2021.01 or newer, and PowerShell on Windows. Python 3 is optional but
recommended: the export scripts use it to verify the STLs.

Windows (PowerShell, from the repo root):

```powershell
.\scripts\export_stl.ps1
```

Linux / macOS:

```sh
./scripts/export_stl.sh
```

Generated STLs land in `openscad_scripts/stls/` and are not committed.
The scripts fail if any render fails, export binary STL, render the
ZenDrive box and lid as separate files (the `Both` and `Assembled`
views are previews only), and then run `scripts/check_stl.py`, which
checks each STL's bounding box against the dimensions above and that
its mesh is closed.

To open a model in the OpenSCAD GUI instead, open the `.scad` file
and press F6 to render. The ZenDrive file's `part_to_render`
customizer selects Box, Lid, Both, or Assembled; the tolerance test's
selects Plate, Pins, or Both. From the command line, select a part
with `-D`, for example:

```sh
openscad --render --export-format binstl -D 'part_to_render="Box"' \
  -o zendrive_u9m_box-box.stl \
  openscad_scripts/zendrive_u9m_box/zendrive_u9m_box.scad
```

## Printing notes

- The calibration examples are the place to start: print the cube to
  check dimensions and flow, the temperature tower to pick a
  temperature for a filament, and the tolerance test to pick a
  clearance before printing a fitting part. For the tolerance test,
  flip the pin strip face-down onto the hole plate; the stations line
  up left to right, and clearance is the diametral play
  (hole diameter = pin diameter + clearance).
- The ZenDrive box dimensions are for the ASUS ZenDrive U9M
  (SDRW-08U9M-U). Verify them against your own drive before
  printing. Its lid fit has been verified only by rendering so far —
  the lid renders seated in its groove in the `Assembled` preview —
  and has not yet been test-printed. Print the lid first and check
  that it slides in the groove before committing to the full box.
- Bambu Lab's manuals are not included in this repo. The P1S
  reference here summarizes the manufacturer's published
  specifications; consult the official documentation for the full
  guides.

## Project layout

```text
openscad-toolkit/
├── openscad_scripts/       # OpenSCAD source files
│   ├── examples/           # Calibration and test models
│   └── zendrive_u9m_box/   # ZenDrive U9M storage box
├── printer_information/    # Bambu Lab P1S reference
├── profiles/               # Starter print profile (mapping reference)
├── scripts/                # STL export (PowerShell + shell) and STL checks
└── .github/workflows/      # CI: renders and checks every model
```

## History

Version 2.0.0 (2026-10-28) is a fresh single-commit export.
Previously prepared as ss-openSCAD; renamed to openscad-toolkit
before publishing, and the ss-openSCAD export is superseded — do not
push it. The original 2026-07-19 history is not carried over: it was a single
commit under a student email address, and it bundled Bambu Lab's
copyrighted manuals (an 18 MB PDF) into the repository. The code in
that history contained no secrets or personal data, but the history
itself is not suitable for a public repo, so it was left behind
rather than pushed. See `CHANGELOG.md` for what changed in 2.0.0.

## License

[MIT](LICENSE)
