/*
Shared fit arithmetic for this repo.

Import with `use`, not `include` (see lib/labels.scad for why).

Clearance is diametral play, the rule this repo's tolerance test
exists to measure: hole_diameter = pin_diameter + clearance. A
clearance of 0 is line-to-line, a negative clearance is an
interference fit, and a larger positive clearance is looser. The
pin diameter is the same at every station; only the hole changes.
*/

/* Hole diameter for a pin of `pin_dia` at the given clearance. */
function hole_dia(pin_dia, clearance) = pin_dia + clearance;

/* Hole radius, for cylinder(r = ...) call sites. */
function hole_radius(pin_dia, clearance) = hole_dia(pin_dia, clearance) / 2;
