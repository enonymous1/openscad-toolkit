/*
Printer constants for this repo, currently for the Bambu Lab P1S only.

Import with `use`, not `include` (see lib/labels.scad for why). Note
the consequence: `use` imports modules and functions but not
variables, so these constants are functions, not variables. A model
that needs them calls build_volume()[0] and so on. If a second
printer is ever added, add a second file (for example, lib/p2s.scad)
rather than parameterizing this one: a printer's constants travel
together, and a parameterized printer file would let a model silently
mix two printers' numbers.
*/

/* Build volume in mm, as [x, y, z]. */
function build_volume() = [256, 256, 256];

/* Stock nozzle diameter in mm. */
function nozzle_dia() = 0.4;
