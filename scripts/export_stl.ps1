<#
.SYNOPSIS
    Render every OpenSCAD model in this repo to binary STL.

.DESCRIPTION
    Renders the three calibration examples and the ZenDrive box and lid
    into openscad_scripts/stls/. The ZenDrive "Both" and "Assembled"
    previews are not exported: a single STL holding two separate solids
    is confusing to slice, so Box and Lid are exported separately with
    the part selected via -D. Each target STL is deleted before its
    render, so a failed run never leaves a previous STL in place to be
    sliced by mistake.

    Requires OpenSCAD 2021.01 (or a newer nightly) on PATH as
    openscad.exe, at the default install location, or passed with
    -OpenSCADPath. If Python is available, scripts/check_stl.py is run
    afterwards to verify each STL's bounding box and closed mesh.

.EXAMPLE
    .\scripts\export_stl.ps1
.EXAMPLE
    .\scripts\export_stl.ps1 -OpenSCADPath "C:\Tools\OpenSCAD\openscad.exe" -OutDir "C:\Temp\stls"
#>
[CmdletBinding()]
param(
    [string]$OpenSCADPath = "",
    [string]$OutDir = ""
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
if (-not $OutDir) { $OutDir = Join-Path $RepoRoot "openscad_scripts\stls" }
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }

# Clear previously generated outputs up front: deleting each target
# only as it is rendered would still leave stale files for models
# never reached after an early failure.
@("calibration_cube.stl", "temperature_tower.stl", "tolerance_test-plate.stl", "tolerance_test-pins.stl", "zendrive_u9m_box-box.stl", "zendrive_u9m_box-lid.stl") | ForEach-Object {
    $old = Join-Path $OutDir $_
    if (Test-Path $old) { Remove-Item $old }
}

if (-not $OpenSCADPath) {
    $defaultPath = "C:\Program Files\OpenSCAD\openscad.exe"
    if (Test-Path $defaultPath) {
        $OpenSCADPath = $defaultPath
    }
    else {
        $cmd = Get-Command openscad.exe -ErrorAction SilentlyContinue
        if (-not $cmd) { $cmd = Get-Command openscad -ErrorAction SilentlyContinue }
        if ($cmd) { $OpenSCADPath = $cmd.Path }
    }
}
if (-not $OpenSCADPath -or -not (Test-Path $OpenSCADPath)) {
    throw "OpenSCAD not found. Install OpenSCAD 2021.01, add it to PATH, or pass -OpenSCADPath."
}

function Invoke-Render {
    param([string]$Source, [string]$Output, [string]$Define = "")

    $sourcePath = Join-Path $RepoRoot $Source
    if (-not (Test-Path $sourcePath)) { throw "Source not found: $sourcePath" }
    Write-Host "Rendering $Source -> $Output"
    # Delete any previous output first: a failed render must never
    # leave yesterday's STL in place to be sliced by mistake.
    if (Test-Path $Output) { Remove-Item $Output }
    if ($Define) {
        & $OpenSCADPath --render --export-format binstl -D $Define -o $Output $sourcePath
    }
    else {
        & $OpenSCADPath --render --export-format binstl -o $Output $sourcePath
    }
    if ($LASTEXITCODE -ne 0) {
        throw "OpenSCAD failed for $Source (exit code $LASTEXITCODE). No STL was trusted from this run."
    }
}

Invoke-Render "openscad_scripts\examples\calibration_cube.scad" (Join-Path $OutDir "calibration_cube.stl")
Invoke-Render "openscad_scripts\examples\temperature_tower.scad" (Join-Path $OutDir "temperature_tower.stl")
Invoke-Render "openscad_scripts\examples\tolerance_test.scad" (Join-Path $OutDir "tolerance_test-plate.stl") 'part_to_render="Plate"'
Invoke-Render "openscad_scripts\examples\tolerance_test.scad" (Join-Path $OutDir "tolerance_test-pins.stl") 'part_to_render="Pins"'
Invoke-Render "openscad_scripts\zendrive_u9m_box\zendrive_u9m_box.scad" (Join-Path $OutDir "zendrive_u9m_box-box.stl") 'part_to_render="Box"'
Invoke-Render "openscad_scripts\zendrive_u9m_box\zendrive_u9m_box.scad" (Join-Path $OutDir "zendrive_u9m_box-lid.stl") 'part_to_render="Lid"'

Write-Host "Done. STLs are in $OutDir." -ForegroundColor Green

$checker = Join-Path $RepoRoot "scripts\check_stl.py"
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) { $python = Get-Command python3 -ErrorAction SilentlyContinue }
if ($python -and (Test-Path $checker)) {
    Write-Host "Checking STLs with check_stl.py..."
    & $python.Path $checker $OutDir
    if ($LASTEXITCODE -ne 0) { throw "check_stl.py failed. See the output above." }
}
else {
    Write-Warning "Python not found; STL bounding-box checks were skipped. Run: python scripts/check_stl.py $OutDir"
}
