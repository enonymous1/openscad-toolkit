Bambu P1S starter profile (notes)

This folder holds `bambu_p1s_profile.sample.json`, a mapping reference:
recommended starting values for print settings, in plain JSON. It is
not a Bambu Studio profile file and cannot be imported into Bambu
Studio as-is. Bambu Studio uses its own profile format; use this JSON
as a quick reference and copy the values into a custom profile by hand,
or as the input to a converter if you write one.

Suggested workflow:

1. In Bambu Studio, create a new custom profile for the P1S.
2. Copy values from `bambu_p1s_profile.sample.json` into the
   corresponding settings in the profile editor (nozzle, layer height,
   temperatures, speeds, retraction, fan, and so on).
3. Save and name the profile (for example, "P1S - Starter PLA").
4. Tune the profile by printing the calibration examples in
   `openscad_scripts/examples/`: the calibration cube, the tolerance
   test, and the temperature tower.

The values are starting points taken from the manufacturer's published
specifications and the reference in `printer_information/bambu_p1s.md`.
They are not a substitute for calibrating your own filament on your
own printer. Bed and hotend temperatures in the JSON are per-filament
starting values; never exceed the printer's maximum temperatures
(300 °C hotend, 100 °C bed).

AMS note: the Bambu Lab Quick Start Guide recommends using Bambu
Filament with the AMS and avoiding very soft or damp filaments (such
as TPU and damp PVA), which can jam. See Bambu Lab's official P1S
documentation, linked from `printer_information/bambu_p1s.md`, for the
full guidance. This repo does not redistribute Bambu Lab's manuals.
