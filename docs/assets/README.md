# Visual assets

Renders in this folder, not photographs. No printed-part photograph
belongs here until a real print exists — the lid fit is still
render-verified only, so a staged print photo would misrepresent it.

## How each asset was captured

All renders use OpenSCAD 2021.01 in preview mode (not `--render`):
preview mode keeps the `color()` values from
`zendrive_u9m_box.scad` (dark box, light lid), while a full `--render`
export recolors everything to OpenSCAD's default gold. Preview meshes
are approximate, but these models are flat-faced boxes, so the preview
is faithful for a picture; the STL verification in
`scripts/check_stl.py` is a separate, exact check. PNG export needs a
display, so the commands below run under `xvfb-run -a` on headless
machines.

### hero-assembled.png (1200 × 900)

```sh
xvfb-run -a openscad --export-format png --imgsize=1200,900 \
  --camera=75,87,11,60,0,35,400 -D 'part_to_render="Assembled"' \
  -o docs/assets/hero-assembled.png \
  openscad_scripts/zendrive_u9m_box/zendrive_u9m_box.scad
```

Camera: centered on the assembled box (75, 87, 11), 60° X-rotation,
35° Z-rotation, distance 400. Shows the lid seated in the groove,
the ZenDrive engraving, the grip, and the finger notch.

### calibration-trio.png (1800 × 600)

Three preview renders at the same 60°/35° camera angle, one per panel
(800 × 800 each), composited side by side with Pillow and downscaled
to 1800 × 600. Distances differ per panel so each model fills its
panel (a single shared distance would shrink the 20 mm cube to a
speck or crop the 120 mm tolerance test); the panels are therefore
not to a common scale, and the README does not claim they are.

```sh
xvfb-run -a openscad --export-format png --imgsize=800,800 \
  --camera=0,0,0,60,0,35,90 \
  -o /tmp/trio-cube.png openscad_scripts/examples/calibration_cube.scad
xvfb-run -a openscad --export-format png --imgsize=800,800 \
  --camera=0,0,35,60,0,35,280 \
  -o /tmp/trio-tower.png openscad_scripts/examples/temperature_tower.scad
xvfb-run -a openscad --export-format png --imgsize=800,800 \
  --camera=0,11,2,60,0,35,420 -D 'part_to_render="Both"' \
  -o /tmp/trio-tolerance.png openscad_scripts/examples/tolerance_test.scad
python3 - <<'PY'
from PIL import Image
imgs = [Image.open(f"/tmp/trio-{n}.png") for n in ("cube", "tower", "tolerance")]
w, h = imgs[0].size
trio = Image.new("RGB", (w * 3, h), (255, 255, 255))
for i, im in enumerate(imgs):
    trio.paste(im.convert("RGB"), (i * w, 0))
trio = trio.resize((1800, 600), Image.LANCZOS)
trio.save("docs/assets/calibration-trio.png", optimize=True)
PY
```

Left to right: 20 mm calibration cube, temperature tower with all
seven embossed labels (190–220) legible, and the tolerance test in
its Both preview (hole plate in front, pin strip behind).

## Planned, not yet captured

- `tolerance-closeup.png`: one tolerance station engaged (needs a
  real print or a closer preview crop).
- `lid-section.svg`: dimensioned cross-section through the groove.
- `export-demo.gif`: a real terminal run of `./scripts/export_stl.sh`
  ending in the six PASS lines (record, do not stage the text).
