# Shared OpenSCAD library (`openscad_scripts/lib/`)

Modules and functions used by more than one model, so the pattern
lives in exactly one place. A model that uses only its own geometry
(such as the calibration cube) imports nothing from here.

## Files

| File | Provides | Used by |
| --- | --- | --- |
| `labels.scad` | `label_overlap()`, `emboss_label()`, `engrave_label()` | Temperature tower, tolerance test, ZenDrive lid |
| `fit.scad` | `hole_dia()`, `hole_radius()` | Tolerance test |
| `printer.scad` | `build_volume()`, `nozzle_dia()` (Bambu Lab P1S) | ZenDrive box |

## Import rule: `use`, never `include`

```scad
use <../lib/labels.scad>;
```

`use` imports only modules and functions, so library code never leaks
variables into a model's Customizer. That is also why printer
constants are functions (`build_volume()`) rather than variables:
`use` does not import variables at all.

## Semantics worth knowing

- `emboss_label(label, size, proud, ...)`: the caller positions the
  module origin `label_overlap()` (0.2 mm) inside the host surface,
  and the module extrudes `proud + label_overlap()` outward, so the
  label stands exactly `proud` above the surface. The tolerance
  labels pass `proud = 0.6`: the original code extruded 0.8 mm from
  0.2 mm below the top face, which is 0.6 mm above it.
- `engrave_label(label, size, depth, ...)`: for use inside
  `difference()`. The caller places the origin exactly on the host
  surface; the module cuts `depth` into it. The ZenDrive lid
  engraving is now exactly `text_depth` (1.0 mm) deep; the original
  inline code started 0.05 mm high, so its cut was 0.95 mm deep.
  Outer dimensions and triangle counts are unchanged.
- `hole_radius(pin_dia, clearance)`: diametral play —
  hole = pin + clearance, larger clearance is looser.

## Deliberately not in here

- The ZenDrive lid engraving's font and placement stay with the lid:
  only the cut pattern is shared, not the lid's design choices.
- No box/lid split library: the ZenDrive box and lid share
  dimensions through the one file they already live in, and splitting
  them would add a shared-dimensions file for a single model.
