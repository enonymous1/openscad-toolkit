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

use <../lib/labels.scad>;
use <../lib/printer.scad>;

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
// Divider wall between the drive and cable cavities. It was
// wall_thickness / 2 written inline in two places; naming it keeps
// the cavity-layout arithmetic in one place (see inner_w below).
divider_t = 1.5;
// Overlap used when joining two solids so they render as one solid
// instead of two solids touching at a face (lid handle into plate).
join_overlap = 0.2;
// Extra depth on through-cuts so they never leave a zero-thickness
// face behind (the lid groove must cut cleanly past the top of the
// body).
cut_overshoot = 0.1;
// How far the lid top sits below the body top: the lid plate is
// floor_thickness thick, so the groove is floor_thickness +
// lid_recess deep and the seated lid is recessed by lid_recess.
lid_recess = 1.0;
// Clearance kept between the divider top and the lid-groove floor so
// the seated lid slides over the divider instead of rubbing it, even
// with minor over-extrusion. The divider is lowered to meet this,
// not the lid: the groove floor is the sliding datum.
divider_clearance = 0.2;
// Overlap of the divider into the floor and the side walls, so it
// renders as one solid with the body.
divider_overlap = 0.5;

/* [Color Scheme (Preview Only)] */
color_box = [0.2, 0.2, 0.2];
color_lid = [0.75, 0.75, 0.75];

/* [Derived Dimensions] */
inner_l = drive_l + (clearance * 2);
// inner_w is the sum of the actual cavity layout, left to right:
// drive cavity (drive_w + clearance on both sides) + divider +
// cable cavity. An earlier version used clearance * 3 here, which
// made inner_w 0.5 mm short and let the cable cavity cut 0.5 mm into
// what should have been a 3 mm wall on the cable side.
inner_w = drive_w + (clearance * 2) + divider_t + cable_slot_w;
inner_h = drive_h + (clearance * 2);

outer_l = inner_l + (wall_thickness * 2);
outer_w = inner_w + (wall_thickness * 2);
outer_h = inner_h + wall_thickness + floor_thickness;

// Lid width: the groove is outer_w - wall_thickness wide, and the lid
// is lid_tolerance narrower than the groove, for a sliding fit.
lid_w = outer_w - wall_thickness - lid_tolerance;
// Groove floor: the groove is floor_thickness + lid_recess deep, so
// the seated lid plate (floor_thickness thick) sits lid_recess below
// the body top. The groove cut itself is floor_thickness +
// lid_recess + cut_overshoot tall, so it cuts cleanly past the top.
groove_z = outer_h - floor_thickness - lid_recess;
// Divider height: from its overlap into the floor up to
// divider_clearance below the groove floor (see divider_clearance).
divider_h = groove_z - divider_clearance - (wall_thickness - divider_overlap);

assert(clearance >= 0, "clearance must not be negative");
assert(lid_tolerance >= 0 && lid_tolerance < wall_thickness,
       "lid_tolerance must be positive and smaller than wall_thickness");
assert(wall_thickness > 0 && floor_thickness > 0, "thicknesses must be positive");
assert(divider_t > 0 && divider_t < cable_slot_w,
       "divider_t must be positive and narrower than the cable cavity");
assert(wall_thickness + drive_w + (clearance * 2) + divider_t + cable_slot_w
         <= wall_thickness + inner_w,
       "cable cavity must end at or before the inner wall");
assert(divider_h > 0, "divider_h must be positive");
assert((wall_thickness - divider_overlap) + divider_h < groove_z,
       "divider top must stay below the lid-groove floor so the lid slides freely");
assert(outer_l <= build_volume()[0] && outer_w <= build_volume()[1]
         && outer_h <= build_volume()[2],
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
                 wall_thickness + drive_w + (clearance * 2) + divider_t,
                 wall_thickness])
        cube([inner_l, cable_slot_w, inner_h]);

      // Lid groove across the top, leaving a side rail at each long edge
      translate([-1, wall_thickness / 2, groove_z])
        cube([outer_l + 2, outer_w - wall_thickness,
              floor_thickness + lid_recess + cut_overshoot]);

      // Finger notch to pull the drive out
      translate([outer_l - wall_thickness - 10, outer_w / 2 - 15, outer_h - 10])
        cube([15, 30, 20]);
    }

    // Divider between the drive and cable cavities: the wall left
    // between the two cavities, overlapped divider_overlap into the
    // floor and the side walls so it renders as one solid with the
    // body, and stopping divider_clearance below the groove floor so
    // the seated lid slides over it instead of rubbing it.
    translate([wall_thickness - divider_overlap,
               wall_thickness + drive_w + (clearance * 2),
               wall_thickness - divider_overlap])
      cube([inner_l + divider_overlap * 2, divider_t, divider_h]);
  }
}

module lid() {
  difference() {
    union() {
      // Main lid plate
      cube([outer_l, lid_w, floor_thickness]);

      // Grip/handle (raised, near one short edge; it does not cover
      // the label, which sits at the center of the plate). It overlaps
      // join_overlap into the plate so handle and plate are one solid.
      translate([5, lid_w / 2 - 15, floor_thickness - join_overlap])
        cube([8, 30, 1.7]);
    }

    // Engraved text, cut into the top face of the plate
    // (lib/labels.scad's engrave_label, origin on the top face, cut
    // exactly text_depth deep).
    // (An earlier version placed a full-footprint pad over the plate
    // that covered the text, hiding the engraving.)
    translate([outer_l / 2, lid_w / 2, floor_thickness])
      engrave_label(label_text, font_size, text_depth, font_style);
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
} else if (part_to_render == "Both") {
  // Preview both, side by side.
  color(color_box) storage_box();
  translate([0, outer_w + 10, 0])
    color(color_lid) lid();
} else {
  // A typo'd part name used to fall through to the Both preview
  // silently and render the wrong part; fail loudly instead.
  assert(false, str("unknown part_to_render: ", part_to_render));
}
