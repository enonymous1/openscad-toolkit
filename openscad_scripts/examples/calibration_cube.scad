/*
Calibration cube — 20 x 20 x 20 mm

Usage:
 - Render (F6) in OpenSCAD and export STL (File -> Export -> Export as STL),
   or use the included export script (`scripts/export_stl.ps1` on Windows,
   `scripts/export_stl.sh` on Linux/macOS).
 - Use this cube to check dimensional accuracy and basic extrusion/flow
   calibration: print it, then measure all three sides with calipers.

The cube is centered on the origin so it is easy to align on the build
plate in the slicer.
*/

/* [Dimensions] */
size = 20; // [10:1:30]

assert(size > 0, "size must be positive");

cube([size, size, size], center = true);
