"""Create no-auth Open Images downloader lists for known-safe classes.

This consumes the official Open Images class-description and human-verified
image-label CSV files. It never downloads personal data, accepts no API key,
and does not create hidden-camera positive labels.
"""

from __future__ import annotations

import argparse
import csv
import json
from collections import defaultdict
from pathlib import Path

from common import KNOWN_SAFE_CLASSES

CLASS_ALIASES = {
    "laptop": {"laptop"},
    "phone": {"mobile phone", "smartphone"},
    "tablet": {"tablet computer"},
    "smart_speaker": {"smart speaker", "speaker"},
    "tv_monitor": {"television", "television set"},
    "monitor": {"computer monitor", "monitor"},
}


def class_ids(descriptions: Path) -> dict[str, set[str]]:
    found: dict[str, set[str]] = defaultdict(set)
    with descriptions.open(newline="", encoding="utf-8-sig") as handle:
        for row in csv.reader(handle):
            if len(row) < 2:
                continue
            mid, display_name = row[0].strip(), row[1].strip().lower()
            for target, aliases in CLASS_ALIASES.items():
                if display_name in aliases:
                    found[target].add(mid)
    missing = [name for name in KNOWN_SAFE_CLASSES if not found.get(name)]
    if missing:
        raise ValueError(f"Classes absent from descriptions: {', '.join(missing)}")
    return dict(found)


def build_lists(descriptions: Path, annotations: Path, split: str, output: Path, max_per_class: int) -> dict:
    ids = class_ids(descriptions)
    reverse = {mid: target for target, mids in ids.items() for mid in mids}
    selected: dict[str, list[str]] = {name: [] for name in KNOWN_SAFE_CLASSES}
    seen: dict[str, set[str]] = {name: set() for name in KNOWN_SAFE_CLASSES}
    with annotations.open(newline="", encoding="utf-8-sig") as handle:
        reader = csv.DictReader(handle)
        required = {"ImageID", "LabelName", "Confidence"}
        if not required.issubset(reader.fieldnames or []):
            raise ValueError(f"Annotation CSV must contain {sorted(required)}")
        for row in reader:
            target = reverse.get(row["LabelName"])
            if target is None or float(row["Confidence"]) != 1.0:
                continue
            image_id = row["ImageID"].strip()
            if image_id in seen[target] or len(selected[target]) >= max_per_class:
                continue
            seen[target].add(image_id)
            selected[target].append(image_id)
    output.mkdir(parents=True, exist_ok=True)
    for target, image_ids in selected.items():
        (output / f"open_images_{target}_{split}.txt").write_text(
            "".join(f"{split}/{image_id}\n" for image_id in image_ids), encoding="utf-8"
        )
    summary = {
        "source": "Open Images",
        "annotation_type": "human_verified_positive_image_labels",
        "split": split,
        "training_role": "known_safe",
        "counts": {name: len(values) for name, values in selected.items()},
        "class_ids": {name: sorted(values) for name, values in ids.items()},
        "requires_api_key": False,
    }
    (output / "open_images_selection.json").write_text(
        json.dumps(summary, indent=2) + "\n", encoding="utf-8"
    )
    return summary


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--class-descriptions", type=Path, required=True)
    parser.add_argument("--annotations", type=Path, required=True)
    parser.add_argument("--split", choices=("train", "validation", "test"), required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--max-per-class", type=int, default=500)
    args = parser.parse_args()
    if args.max_per_class < 1:
        parser.error("--max-per-class must be positive")
    summary = build_lists(
        args.class_descriptions, args.annotations, args.split,
        args.output, args.max_per_class,
    )
    print(json.dumps(summary["counts"], sort_keys=True))


if __name__ == "__main__":
    main()

