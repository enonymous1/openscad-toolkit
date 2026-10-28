/* ASUS ZenDrive U9M (SDRW-08U9M-U) Storage Box
 * A parametric protective case with a sliding lid.
 *
 * The box is an open-topped shell: a cavity for the drive, a narrower
 * cavity for its USB cables, a divider between them, and a groove
 * across the top that the lid slides into from either short end. The
 * lid sits recessed in that groove, retained by the two remaining
 * side rails. "Assembled" previews the lid seated in the groove;
 * "Both" previews the two parts side by side.
 *
 * Dimensions are for the drive named above. Verify them against your
 * own unit before printing: the fit has not been test-printed from
 * this script. Print the lid first and check it slides in the groove
 * before committing to the full box.
 */

/* [Part] */
// Select which part to render for STL export. "Both" and "Assembled"
// are previews only: export Box and Lid separately.
part_to_render = "Lid"; // [Box, Lid, Both, Assembled]

/* [Physical Dimensions (ASUS ZenDrive U9M)] */
drive_l = 142.5;
drive_w = 135.5;
drive_h = 13.9;

/* [Cable Compartment] */
cable_slot_w = 30; // Extra width for the USB-C and Type-A cables

/* [Text] */
label_text = "ZenDrive";
font_size = 14;
text_depth = 1.0;
font_style = "Liberation Sans:style=Bold"; // OpenSCAD substitutes a fallback if this font is not installed

/* [Design Parameters] */
wall_thickness = 3.0;
floor_thickness = 2.5;
// Increased clearance from 0.6 to 1.0 for a more comfortable "drop-in" fit
clearance = 1.0;
// Increased lid tolerance from 0.2 to 0.4 to ensure the lid slides smoothly even with minor over-extrusion
lid_tolerance = 0.4;

/* [Color Scheme (Preview Only)] */
color_box = [0.2, 0.2, 0.2];
color_lid = [0.75, 0.75, 0.75];
color_text = [0.1, 0.5, 0.9];

/* [Derived Dimensions] */
inner_l = drive_l + (clearance * 2);
inner_w = drive_w + cable_slot_w + (clearance * 3);
inner_h = drive_h + (clearance * 2);

outer_l = inner_l + (wall_thickness * 2);
outer_w = inner_w + (wall_thickness * 2);
outer_h = inner_h + wall_thickness + floor_thickness;

// Lid width: the groove is outer_w - wall_thickness wide, and the lid
// is lid_tolerance narrower than the groove, for a sliding fit.
lid_w = outer_w - wall_thickness - lid_tolerance;
// Groove floor: the groove is cut floor_thickness + 1 into the top.
groove_z = outer_h - floor_thickness - 1;

assert(clearance >= 0, "clearance must not be negative");
assert(lid_tolerance >= 0 && lid_tolerance < wall_thickness,
       "lid_tolerance must be positive and smaller than wall_thickness");
assert(wall_thickness > 0 && floor_thickness > 0, "thicknesses must be positive");
assert(outer_l <= 256 && outer_w <= 256 && outer_h <= 256,
       "outer dimensions must fit the P1S 256 mm build volume");

echo(str("Outer: ", outer_l, " x ", outer_w, " x ", outer_h, " mm; lid width: ", lid_w, " mm"));

module storage_box() {
  union() {
    difference() {
      // Main body
      cube([outer_l, outer_w, outer_h]);

      // Main cavity for the drive (cut through the top)
      translate([wall_thickness, wall_thickness, wall_thickness])
        cube([inner_l, drive_w + (clearance * 2), inner_h + 10]);

      // Cavity for cables
      translate([wall_thickness,
                 wall_thickness + drive_w + (clearance * 2) + wall_thickness / 2,
                 wall_thickness])
        cube([inner_l, cable_slot_w, inner_h]);

      // Lid groove across the top, leaving a side rail at each long edge
      translate([-1, wall_thickness / 2, groove_z])
        cube([outer_l + 2, outer_w - wall_thickness, floor_thickness + 1.1]);

      // Finger notch to pull the drive out
      translate([outer_l - wall_thickness - 10, outer_w / 2 - 15, outer_h - 10])
        cube([15, 30, 20]);
    }

    // Divider between the drive and cable cavities: the wall left
    // between the two cavities, overlapped 0.5 mm into the floor and
    // the side walls so it renders as one solid with the body.
    translate([wall_thickness - 0.5,
               wall_thickness + drive_w + (clearance * 2),
               wall_thickness - 0.5])
      cube([inner_l + 1, wall_thickness / 2, inner_h + 0.5]);
  }
}

module lid() {
  difference() {
    union() {
      // Main lid plate
      cube([outer_l, lid_w, floor_thickness]);

      // Grip/handle (raised, near one short edge; it does not cover
      // the label, which sits at the center of the plate). It overlaps
      // 0.2 mm into the plate so handle and plate are one solid.
      translate([5, lid_w / 2 - 15, floor_thickness - 0.2])
        cube([8, 30, 1.7]);
    }

    // Engraved text, cut into the top face of the plate. The text
    // solid starts text_depth below the top face and extends 0.1 mm
    // above it, so the cut is exactly text_depth deep and visible.
    // (An earlier version placed a full-footprint pad over the plate
    // that covered the text, hiding the engraving.)
    translate([outer_l / 2, lid_w / 2, floor_thickness - text_depth + 0.05])
      color(color_text)
        linear_extrude(height = text_depth + 0.1)
          text(label_text, size = font_size, font = font_style,
               halign = "center", valign = "center");
  }
}

// Lid seated in the groove: groove floor at groove_z, offset in Y by
// half a wall so it sits between the two side rails.
module lid_seated() {
  translate([0, wall_thickness / 2, groove_z])
    lid();
}

if (part_to_render == "Box") {
  color(color_box) storage_box();
} else if (part_to_render == "Lid") {
  // Rendered at origin for easier slicing. In the slicer, offset Y by
  // wall_thickness/2 only when placing it in the groove (see Assembled).
  color(color_lid) lid();
} else if (part_to_render == "Assembled") {
  color(color_box) storage_box();
  color(color_lid) lid_seated();
} else {
  // Preview both, side by side.
  color(color_box) storage_box();
  translate([0, outer_w + 10, 0])
    color(color_lid) lid();
}
