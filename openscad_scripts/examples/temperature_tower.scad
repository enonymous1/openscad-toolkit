/*
Temperature tower (visual/adhesion test) — stacked sections with embossed
temperature labels on the front face.

How to use:
 - Slice and print each section at a different temperature: either set a
   per-layer temperature change in your slicer at each 10 mm step, or
   change the nozzle temperature manually at each section height.
 - The label embossed on the front face of each section identifies the
   temperature that section was printed at. Read the tower after printing
   to find the temperature with the best layer adhesion and detail for
   that filament. The temperatures here are a PLA starting range; edit
   `temps` for other filaments.

The labels are rotated so the text lies on the front face (y = -depth/2)
and protrudes 0.8 mm toward the viewer. (An earlier version extruded the
text upward in Z, which buried it inside the blocks.)
*/

use <../lib/labels.scad>;

/* [Tower] */
temps = [190, 195, 200, 205, 210, 215, 220];
section_h = 10;
width = 30;
depth = 30;
label_size = 6;
label_proud = 0.8;

assert(len(temps) > 0, "temps must not be empty");
assert(section_h > 0 && width > 0 && depth > 0, "dimensions must be positive");
assert(label_size < section_h, "label_size must fit within one section");

for (i = [0 : len(temps) - 1]) {
  t = temps[i];
  z = i * section_h;
  // Block, centered in X/Y.
  translate([-width / 2, -depth / 2, z])
    cube([width, depth, section_h]);
  // Embossed label on the front face (see lib/labels.scad): the
  // rotation turns the text plane from XY to XZ and the extrusion
  // direction from +Z to -Y, so the text protrudes from the front
  // face instead of rising through the block. The origin sits
  // label_overlap() inside the block, so the label stands
  // label_proud above the face.
  translate([-width / 2 + 2, -depth / 2 + label_overlap(), z + 1])
    emboss_label(t, label_size, label_proud, [90, 0, 0],
                 "left", "baseline");
}
