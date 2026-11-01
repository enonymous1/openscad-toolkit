<#
.SYNOPSIS
    Render every OpenSCAD model in this repo to binary STL.

.DESCRIPTION
    Renders every model listed in models.json at the repo root into
    openscad_scripts/stls/ (or -OutDir). The ZenDrive "Both" and
    "Assembled" previews are not exported: a single STL holding two
    separate solids is confusing to slice, so Box and Lid are exported
    separately with the part selected via -D. Each target STL is
    deleted before its render, so a failed run never leaves a previous
    STL in place to be sliced by mistake. Previously generated outputs
    are also cleared up front, so a failure on an early model does not
    leave stale files for later models behind.

    Requires OpenSCAD 2021.01 (or a newer nightly) on PATH as
    openscad.exe, at the default install location, or passed with
    -OpenSCADPath. The manifest is read with ConvertFrom-Json, so no
    extra tooling is needed to render. If Python is available,
    scripts/check_stl.py is run afterwards to verify each STL's
    bounding box and closed mesh.

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

$ManifestPath = Join-Path $RepoRoot "models.json"
if (-not (Test-Path $ManifestPath)) { throw "models.json not found: $ManifestPath" }
$Manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json

# Clear previously generated outputs up front: deleting each target
# only as it is rendered would still leave stale files for models
# never reached after an early failure.
foreach ($model in $Manifest.models) {
    foreach ($output in $model.outputs) {
        $old = Join-Path $OutDir $output.file
        if (Test-Path $old) { Remove-Item $old }
    }
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

foreach ($model in $Manifest.models) {
    foreach ($output in $model.outputs) {
        $define = ""
        if ($output.define) { $define = $output.define }
        Invoke-Render $model.source (Join-Path $OutDir $output.file) $define
    }
}

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
