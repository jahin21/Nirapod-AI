from __future__ import annotations

import csv
import tempfile
import unittest
import zipfile
from pathlib import Path

from common import KNOWN_SAFE_CLASSES
from ingest_public_dataset import _safe_extract
from open_images_known_safe import build_lists


class DataToolsTest(unittest.TestCase):
    def test_only_known_safe_classes_are_supported(self):
        self.assertEqual(
            set(KNOWN_SAFE_CLASSES),
            {"laptop", "phone", "tablet", "smart_speaker", "tv_monitor", "monitor"},
        )

    def test_open_images_lists_use_verified_positive_labels(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            descriptions = root / "classes.csv"
            descriptions.write_text(
                "/m/laptop,Laptop\n/m/phone,Mobile phone\n/m/tablet,Tablet computer\n"
                "/m/speaker,Speaker\n/m/tv,Television\n/m/monitor,Computer monitor\n",
                encoding="utf-8",
            )
            annotations = root / "labels.csv"
            with annotations.open("w", newline="", encoding="utf-8") as handle:
                writer = csv.DictWriter(handle, fieldnames=("ImageID", "Source", "LabelName", "Confidence"))
                writer.writeheader()
                writer.writerow({"ImageID": "good", "Source": "verification", "LabelName": "/m/laptop", "Confidence": "1"})
                writer.writerow({"ImageID": "absent", "Source": "verification", "LabelName": "/m/laptop", "Confidence": "0"})
            output = root / "out"
            result = build_lists(descriptions, annotations, "train", output, 5)
            self.assertEqual(result["counts"]["laptop"], 1)
            self.assertEqual((output / "open_images_laptop_train.txt").read_text(), "train/good\n")

    def test_zip_path_traversal_is_rejected(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            archive = root / "bad.zip"
            with zipfile.ZipFile(archive, "w") as zipped:
                zipped.writestr("../escape.jpg", b"not-an-image")
            with self.assertRaises(ValueError):
                _safe_extract(archive, root / "output")


if __name__ == "__main__":
    unittest.main()
