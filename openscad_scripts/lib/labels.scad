/*
Shared label modules for this repo.

Import with `use`, not `include`:

  use <../lib/labels.scad>;

`use` imports only modules and functions, so nothing here leaks
variables into the Customizer of the model that imports it. (That is
also why printer constants live in printer.scad as functions, not
variables: `use` does not import variables at all.)

The pattern these modules capture: a label must overlap into its host
solid, or it renders as a second solid touching at a face and the
slicer complains. Every embossed label in this repo therefore sinks
label_overlap() into its host and stands `proud` above the surface;
every engraved label cuts cleanly through the surface it sits on.
*/

/* Overlap of an embossed label into its host solid, in mm. Callers
   position the module origin this far inside the host surface, on
   the inward side, and the module extrudes proud + label_overlap()
   outward, so the label stands exactly `proud` above the surface. */
function label_overlap() = 0.2;

/* Embossed label. `label` is converted with str(), so numbers pass
   through unchanged. `proud` is how far the label stands above the
   host surface; the extrusion is proud + label_overlap() because
   the origin sits label_overlap() inside the host (see above).
   `rotation` maps the +Z extrusion direction onto the surface's
   outward normal: [0, 0, 0] for a top face (extrusion straight up),
   [90, 0, 0] for a front face at -Y (rotation turns the text plane
   from XY to XZ and the extrusion direction from +Z to -Y). */
module emboss_label(label, size, proud, rotation = [0, 0, 0],
                    halign = "center", valign = "center") {
  rotate(rotation)
    linear_extrude(height = proud + label_overlap())
      text(str(label), size = size, halign = halign, valign = valign);
}

/* Engraved label, for use inside difference(). The caller places the
   module origin exactly on the host surface; the module cuts `depth`
   into the surface and extends 0.1 mm above it so the top face is
   cut cleanly, never left with a zero-thickness skin. `font` may be
   left at its default when the caller's font does not matter. */
module engrave_label(label, size, depth, font = undef,
                     halign = "center", valign = "center") {
  translate([0, 0, -depth])
    linear_extrude(height = depth + 0.1)
      text(label, size = size, font = font, halign = halign, valign = valign);
}
