/*
Tolerance test — a hole plate and a matching pin strip with varied
clearances, to find the friction fit for your filament and settings.

Clearance is diametral play: hole_diameter = pin_diameter + clearance.
A clearance of 0 is line-to-line, a negative clearance is an
interference fit, and a larger positive clearance is looser. The pin
diameter is the same at every station; only the hole changes.

How to use:
 - Render (F6) and export STL, or use the included export script, which
   renders the plate and the pin strip as separate STLs
   (`-D part_to_render="Plate"` / `"Pins"`).
 - Print both parts. Flip the pin strip face-down onto the hole plate:
   the stations line up left to right, in the same order. Press each pin
   into its matching hole and note which clearance gives a good friction
   fit. The clearance value is embossed on the top face of each part,
   between the rows on the plate and below the pins on the strip.

Layout: one station per clearance, at the same X position on both
parts. Pins stand on a 3 mm strip; holes go all the way through the
6 mm plate. (An earlier version translated the pins and holes twice,
which put most of them off the plate entirely, and grew the pins while
shrinking the holes as clearance increased.)
*/

/* [Part] */
// Select which part to render for STL export. "Both" is preview only:
// export the parts separately.
part_to_render = "Both"; // [Plate, Pins, Both]

/* [Dimensions] */
plate_w = 120;
plate_d = 30;
plate_t = 6;
strip_d = 16;
strip_t = 3;
pin_dia = 4;
pin_h = 6;
spacing = 18;
clearances = [-0.2, 0.0, 0.1, 0.2, 0.3, 0.4];

// Rows, measured from the plate/strip center line.
pin_row_y = -plate_d / 4;
hole_row_y = plate_d / 4;

// X position of station i, centered on the plate.
function station_x(i) = (i - (len(clearances) - 1) / 2) * spacing;

assert(len(clearances) > 0, "clearances must not be empty");
assert(spacing > pin_dia + 2, "spacing must leave material between stations");
assert(plate_w > len(clearances) * spacing, "plate_w must fit all stations");
assert(pin_h > 0 && plate_t > 0 && strip_t > 0, "thicknesses must be positive");

module hole_plate() {
  union() {
    difference() {
      cube([plate_w, plate_d, plate_t], center = true);
      for (i = [0 : len(clearances) - 1])
        translate([station_x(i), hole_row_y, -1])
          cylinder(h = plate_t + 2,
                   r = (pin_dia + clearances[i]) / 2, $fn = 64);
    }
    // Clearance labels, raised on the top face between the rows.
    // They overlap 0.2 mm into the plate so label and plate are one solid.
    for (i = [0 : len(clearances) - 1])
      translate([station_x(i), 0, plate_t / 2 - 0.2])
        linear_extrude(height = 0.8)
          text(str(clearances[i]), size = 3.5,
               halign = "center", valign = "center");
  }
}

module pin_strip() {
  union() {
    cube([plate_w, strip_d, strip_t], center = true);
    for (i = [0 : len(clearances) - 1])
      translate([station_x(i), 0, strip_t / 2])
        cylinder(h = pin_h, r = pin_dia / 2, $fn = 64);
    // Clearance labels, raised on the top face below the pins.
    // They overlap 0.2 mm into the strip so label and strip are one solid.
    for (i = [0 : len(clearances) - 1])
      translate([station_x(i), -strip_d / 2 + 2.5, strip_t / 2 - 0.2])
        linear_extrude(height = 0.8)
          text(str(clearances[i]), size = 3,
               halign = "center", valign = "center");
  }
}

if (part_to_render == "Plate") {
  hole_plate();
} else if (part_to_render == "Pins") {
  pin_strip();
} else {
  // Preview both, side by side.
  hole_plate();
  translate([0, plate_d / 2 + strip_d / 2 + 6, 0])
    pin_strip();
}
