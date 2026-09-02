"""Create a conflict-free four-class view without altering source images."""

from __future__ import annotations

import argparse
import json
import os
import shutil
from collections import defaultdict
from pathlib import Path


MAPPING = {
    "laptop": "laptop",
    "phone": "phone",
    "tablet": "tablet",
    "monitor": "screen_display",
    "tv_monitor": "screen_display",
}
SPLITS = ("train", "validation", "test")


def link_or_copy(source: Path, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    try:
        os.link(source, destination)
    except OSError:
        shutil.copy2(source, destination)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    if args.output.exists() and any(args.output.iterdir()):
        raise SystemExit(f"Output must be absent or empty: {args.output}")

    report = {"mapping": MAPPING, "splits": {}}
    for split in SPLITS:
        by_id: dict[str, list[tuple[str, Path]]] = defaultdict(list)
        for source_class, target_class in MAPPING.items():
            for path in sorted((args.source / split / source_class).glob("*.jpg")):
                by_id[path.stem.lower()].append((target_class, path))

        counts = defaultdict(int)
        collapsed_same_target = 0
        rejected_conflicts = []
        for image_id, candidates in sorted(by_id.items()):
            target_classes = {target for target, _ in candidates}
            if len(target_classes) != 1:
                rejected_conflicts.append({
                    "image_id": image_id,
                    "target_classes": sorted(target_classes),
                    "source_classes": sorted(path.parent.name for _, path in candidates),
                })
                continue
            target_class = next(iter(target_classes))
            if len(candidates) > 1:
                collapsed_same_target += len(candidates) - 1
            source = candidates[0][1]
            link_or_copy(source, args.output / split / target_class / source.name)
            counts[target_class] += 1
        report["splits"][split] = {
            "counts": dict(sorted(counts.items())),
            "collapsed_same_target_duplicates": collapsed_same_target,
            "rejected_cross_target_conflicts": len(rejected_conflicts),
            "rejected": rejected_conflicts,
        }
    (args.output / "PREPARATION_REPORT.json").write_text(
        json.dumps(report, indent=2) + "\n", encoding="utf-8"
    )
    print(json.dumps(report["splits"], indent=2))


if __name__ == "__main__":
    main()
