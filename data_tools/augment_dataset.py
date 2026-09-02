"""Expand reviewed training images using phone-capture-style augmentation."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import albumentations as A
import cv2

from common import iter_images, safe_name, sha256_file


def pipeline():
    return A.Compose([
        A.Affine(scale=(0.85, 1.15), translate_percent=(-0.07, 0.07), rotate=(-18, 18), p=0.85),
        A.OneOf([
            A.RandomBrightnessContrast(brightness_limit=0.28, contrast_limit=0.25),
            A.HueSaturationValue(hue_shift_limit=8, sat_shift_limit=18, val_shift_limit=24),
        ], p=0.8),
        A.OneOf([A.GaussianBlur(blur_limit=(3, 7)), A.MotionBlur(blur_limit=7)], p=0.35),
        A.CoarseDropout(num_holes_range=(1, 5), hole_height_range=(0.03, 0.14),
                        hole_width_range=(0.03, 0.14), fill=0, p=0.35),
        A.GaussNoise(std_range=(0.01, 0.06), p=0.35),
    ])


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--multiplier", type=int, default=10, choices=range(1, 21))
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    transform = pipeline()
    manifest = args.output / "augmentation_manifest.jsonl"
    total = 0
    with manifest.open("w", encoding="utf-8") as handle:
        for source in iter_images(args.input):
            image = cv2.imread(str(source), cv2.IMREAD_COLOR)
            if image is None:
                continue
            digest = sha256_file(source)
            for index in range(args.multiplier):
                result = transform(image=image)["image"]
                filename = f"aug_{safe_name(source.stem)}_{digest[:10]}_{index:02d}.jpg"
                cv2.imwrite(str(args.output / filename), result, [cv2.IMWRITE_JPEG_QUALITY, 92])
                handle.write(json.dumps({
                    "image": filename, "source_sha256": digest,
                    "augmentation_index": index, "derived": True,
                }) + "\n")
                total += 1
    print(f"augmented={total} manifest={manifest}")


if __name__ == "__main__":
    main()

