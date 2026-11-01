"""Tests for scripts/check_stl.py.

Builds synthetic STLs in a temp dir: a valid binary tetrahedron, the
same tetrahedron as ASCII, an open mesh (one triangle removed, so an
edge is shared only once), a wrong-bounding-box file, a malformed
ASCII file, plus missing and empty files. No OpenSCAD needed, so this
runs anywhere CI runs.

Run from the repo root: python3 -m unittest discover tests -v
"""

import struct
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))

import check_stl  # noqa: E402

# A tetrahedron: every edge is shared by exactly two triangles, so it
# is a minimal closed mesh. Bounding box (0, 0, 0)..(1, 1, 1).
VERTS = [(0.0, 0.0, 0.0), (1.0, 0.0, 0.0), (0.0, 1.0, 0.0), (0.0, 0.0, 1.0)]
TRIS = [(0, 1, 2), (0, 3, 1), (0, 2, 3), (1, 3, 2)]
BBOX_MIN = (0.0, 0.0, 0.0)
BBOX_MAX = (1.0, 1.0, 1.0)


def binary_stl(tris):
    """Encode triangles (index triples into VERTS) as a binary STL."""
    out = bytearray(b"\0" * 80 + struct.pack("<I", len(tris)))
    for tri in tris:
        verts = [VERTS[i] for i in tri]
        out += struct.pack(
            "<12fH", 0, 0, 0, *verts[0], *verts[1], *verts[2], 0
        )
    return bytes(out)


def ascii_stl(tris):
    """Encode triangles (index triples into VERTS) as an ASCII STL."""
    lines = ["solid test"]
    for tri in tris:
        lines.append("  facet normal 0 0 0")
        lines.append("    outer loop")
        for i in tri:
            v = VERTS[i]
            lines.append(f"      vertex {v[0]} {v[1]} {v[2]}")
        lines.append("    endloop")
        lines.append("  endfacet")
    lines.append("endsolid test")
    return ("\n".join(lines) + "\n").encode("utf-8")


class CheckFileTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.dir = Path(self.tmp.name)

    def tearDown(self):
        self.tmp.cleanup()

    def write(self, name, data):
        path = self.dir / name
        path.write_bytes(data)
        return path

    def test_valid_binary_passes(self):
        path = self.write("ok.stl", binary_stl(TRIS))
        self.assertEqual(check_stl.check_file(path, BBOX_MIN, BBOX_MAX), [])

    def test_valid_ascii_passes(self):
        path = self.write("ok.stl", ascii_stl(TRIS))
        self.assertEqual(check_stl.check_file(path, BBOX_MIN, BBOX_MAX), [])

    def test_open_mesh_fails(self):
        # Dropping one triangle leaves its three edges shared once.
        path = self.write("open.stl", binary_stl(TRIS[:-1]))
        errors = check_stl.check_file(path, BBOX_MIN, BBOX_MAX)
        self.assertTrue(any("not closed" in e for e in errors), errors)

    def test_wrong_bbox_fails(self):
        path = self.write("wrong.stl", binary_stl(TRIS))
        errors = check_stl.check_file(path, BBOX_MIN, (2.0, 2.0, 2.0))
        self.assertTrue(any("bbox" in e for e in errors), errors)

    def test_malformed_ascii_fails_cleanly(self):
        # A garbage vertex must be a FAIL line, not a traceback.
        path = self.write("bad.stl", b"solid x\n  facet normal 0 0 0\n"
                                     b"    outer loop\n      vertex a b c\n")
        errors = check_stl.check_file(path, BBOX_MIN, BBOX_MAX)
        self.assertTrue(any("unparseable" in e for e in errors), errors)

    def test_garbage_file_reports_no_triangles(self):
        path = self.write("junk.stl", b"this is not an stl file\n")
        errors = check_stl.check_file(path, BBOX_MIN, BBOX_MAX)
        self.assertTrue(any("no triangles parsed" in e for e in errors), errors)

    def test_missing_file(self):
        errors = check_stl.check_file(
            self.dir / "missing.stl", BBOX_MIN, BBOX_MAX
        )
        self.assertTrue(any("missing" in e for e in errors), errors)

    def test_empty_file(self):
        path = self.write("empty.stl", b"")
        errors = check_stl.check_file(path, BBOX_MIN, BBOX_MAX)
        self.assertTrue(any("empty" in e for e in errors), errors)


if __name__ == "__main__":
    unittest.main()
