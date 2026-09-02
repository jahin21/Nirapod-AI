"""Audit fixed known-safe splits and render a small review contact sheet."""

from __future__ import annotations

import argparse
import hashlib
import json
from collections import defaultdict
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, UnidentifiedImageError


SPLITS = ("train", "validation", "test")


def digest(path: Path) -> str:
    value = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            value.update(chunk)
    return value.hexdigest()


def audit(root: Path) -> dict:
    counts: dict[str, dict[str, int]] = {}
    ids_by_split: dict[str, set[str]] = {}
    hashes: dict[str, set[str]] = defaultdict(set)
    invalid: list[str] = []
    for split in SPLITS:
        split_root = root / split
        counts[split] = {}
        ids_by_split[split] = set()
        for class_root in sorted(path for path in split_root.iterdir() if path.is_dir()):
            images = sorted(class_root.glob("*.jpg"))
            counts[split][class_root.name] = len(images)
            for image_path in images:
                ids_by_split[split].add(image_path.stem.lower())
                hashes[digest(image_path)].add(split)
                try:
                    with Image.open(image_path) as image:
                        image.verify()
                except (OSError, UnidentifiedImageError):
                    invalid.append(str(image_path))
    id_overlap = {
        f"{left}_{right}": sorted(ids_by_split[left] & ids_by_split[right])
        for index, left in enumerate(SPLITS)
        for right in SPLITS[index + 1 :]
    }
    cross_split_hashes = sorted(
        hash_value for hash_value, splits in hashes.items() if len(splits) > 1
    )
    return {
        "counts": counts,
        "cross_split_image_id_overlap": id_overlap,
        "cross_split_identical_sha256": cross_split_hashes,
        "invalid_images": invalid,
        "leakage_safe": not any(id_overlap.values()) and not cross_split_hashes,
        "notes": [
            "Official Open Images train/validation/test assignments are preserved.",
            "smart_speaker proxy data is excluded under _deferred and requires manual review.",
            "Audit covers untouched official-split files; training-only augmentation does not modify them.",
        ],
    }


def contact_sheet(root: Path, output: Path, per_class: int = 3) -> None:
    class_names = sorted(path.name for path in (root / "train").iterdir() if path.is_dir())
    tile_width, tile_height, label_height = 240, 180, 34
    sheet = Image.new("RGB", (tile_width * per_class, (tile_height + label_height) * len(class_names)), "white")
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default(size=18)
    for row, class_name in enumerate(class_names):
        samples = sorted((root / "train" / class_name).glob("*.jpg"))[:per_class]
        for column, path in enumerate(samples):
            with Image.open(path) as source:
                source = source.convert("RGB")
                source.thumbnail((tile_width - 8, tile_height - 8))
                x = column * tile_width + (tile_width - source.width) // 2
                y = row * (tile_height + label_height) + (tile_height - source.height) // 2
                sheet.paste(source, (x, y))
            draw.text(
                (column * tile_width + 8, row * (tile_height + label_height) + tile_height + 5),
                f"{class_name}: {path.stem}",
                fill="black",
                font=font,
            )
    output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output, quality=92)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, required=True)
    parser.add_argument("--report", type=Path, required=True)
    parser.add_argument("--contact-sheet", type=Path, required=True)
    args = parser.parse_args()
    result = audit(args.root)
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    contact_sheet(args.root, args.contact_sheet)
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
