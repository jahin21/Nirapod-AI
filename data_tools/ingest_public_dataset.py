"""Safely reformat a downloaded/licensed public image dataset."""

from __future__ import annotations

import argparse
import csv
import shutil
import tempfile
import urllib.request
import zipfile
from pathlib import Path

from common import KNOWN_SAFE_CLASSES, iter_images, safe_name, sha256_file, write_json


def _safe_extract(archive: Path, destination: Path) -> None:
    destination = destination.resolve()
    with zipfile.ZipFile(archive) as zipped:
        for member in zipped.infolist():
            resolved = (destination / member.filename).resolve()
            if destination not in resolved.parents and resolved != destination:
                raise ValueError(f"Unsafe archive member: {member.filename}")
        zipped.extractall(destination)


def _download(url: str, destination: Path, max_mb: int) -> None:
    if not url.lower().startswith("https://"):
        raise ValueError("Only HTTPS dataset URLs are allowed")
    lowered = url.lower()
    forbidden = ("api_key=", "apikey=", "access_token=", "token=", "authorization=")
    if any(value in lowered for value in forbidden):
        raise ValueError("Authenticated or tokenized dataset URLs are not allowed")
    request = urllib.request.Request(url, headers={"User-Agent": "NirapodAI-DatasetTool/1"})
    with urllib.request.urlopen(request, timeout=90) as response, destination.open("wb") as output:
        total = 0
        while chunk := response.read(1024 * 1024):
            total += len(chunk)
            if total > max_mb * 1024 * 1024:
                raise ValueError(f"Dataset exceeds --max-download-mb={max_mb}")
            output.write(chunk)


def main() -> None:
    parser = argparse.ArgumentParser()
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--source-dir", type=Path)
    source.add_argument("--download-url")
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--object-class", choices=KNOWN_SAFE_CLASSES, required=True)
    parser.add_argument("--dataset-name", required=True)
    parser.add_argument("--source-url", required=True)
    parser.add_argument("--license", required=True)
    parser.add_argument("--license-url", required=True)
    parser.add_argument("--max-download-mb", type=int, default=2048)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    manifest_path = args.output / "ingestion_manifest.csv"
    new_manifest = not manifest_path.exists()
    with tempfile.TemporaryDirectory(prefix="nirapod_ingest_") as temporary:
        temporary_path = Path(temporary)
        if args.download_url:
            archive = temporary_path / "dataset.zip"
            _download(args.download_url, archive, args.max_download_mb)
            input_root = temporary_path / "unpacked"
            input_root.mkdir()
            _safe_extract(archive, input_root)
        else:
            input_root = args.source_dir
        images = list(iter_images(input_root))
        copied = 0
        with manifest_path.open("a", newline="", encoding="utf-8") as handle:
            fields = ("image", "sha256", "training_role", "object_class", "dataset_name",
                      "source_url", "license", "license_url", "review_status")
            writer = csv.DictWriter(handle, fieldnames=fields)
            if new_manifest:
                writer.writeheader()
            for image in images:
                digest = sha256_file(image)
                filename = f"{safe_name(args.dataset_name)}_{digest[:16]}{image.suffix.lower()}"
                destination = args.output / filename
                if not destination.exists():
                    shutil.copy2(image, destination)
                    copied += 1
                writer.writerow({
                    "image": filename, "sha256": digest, "training_role": "known_safe",
                    "object_class": args.object_class, "dataset_name": args.dataset_name,
                    "source_url": args.source_url, "license": args.license,
                    "license_url": args.license_url, "review_status": "pending_human_review",
                })
    write_json(args.output / "dataset_provenance.json", {
        "dataset_name": args.dataset_name, "source_url": args.source_url,
        "license": args.license, "license_url": args.license_url,
        "training_role": "known_safe", "object_class": args.object_class,
    })
    print(f"found={len(images)} copied={copied} manifest={manifest_path}")


if __name__ == "__main__":
    main()
