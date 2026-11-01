"""Tests for models.json, the single render list.

The export scripts render exactly what models.json lists, and
scripts/check_stl.py verifies exactly what its EXPECTED table lists.
These tests are the drift guard between the two: if a model is added
to one and not the other, or a manifest source is renamed without
updating the manifest, this suite fails before any rendering happens.
No OpenSCAD needed, so this runs anywhere CI runs.

Run from the repo root: python3 -m unittest discover tests -v
"""

import json
import sys
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent

sys.path.insert(0, str(REPO_ROOT / "scripts"))

import check_stl  # noqa: E402


def load_manifest():
    with (REPO_ROOT / "models.json").open(encoding="utf-8") as f:
        return json.load(f)


class ManifestTest(unittest.TestCase):
    def setUp(self):
        self.manifest = load_manifest()
        self.models = self.manifest["models"]
        self.files = [
            output["file"]
            for model in self.models
            for output in model["outputs"]
        ]

    def test_manifest_is_nonempty(self):
        self.assertTrue(self.models, "models.json lists no models")
        self.assertTrue(self.files, "models.json lists no outputs")

    def test_output_files_are_unique(self):
        self.assertEqual(
            len(self.files),
            len(set(self.files)),
            f"duplicate output files in models.json: {self.files}",
        )

    def test_sources_exist(self):
        for model in self.models:
            source = REPO_ROOT / model["source"]
            self.assertTrue(
                source.is_file(), f"manifest source missing: {model['source']}"
            )

    def test_defines_are_part_selectors(self):
        for model in self.models:
            for output in model["outputs"]:
                define = output.get("define", "")
                self.assertTrue(
                    define == "" or define.startswith('part_to_render="'),
                    f"unexpected define in models.json: {define!r}",
                )

    def test_manifest_matches_checker_expected(self):
        self.assertEqual(
            set(self.files),
            set(check_stl.EXPECTED),
            "models.json outputs and check_stl.EXPECTED disagree; "
            "add the model to both or to neither",
        )


if __name__ == "__main__":
    unittest.main()
