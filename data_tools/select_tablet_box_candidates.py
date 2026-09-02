"""Select exact, visible Tablet computer boxes from official Open Images CSVs."""

from __future__ import annotations

import argparse
import csv
import json
from collections import defaultdict
from pathlib import Path


TABLET_MID = "/m/0bh9flk"
OTHER_TARGET_MIDS = {
    "/m/01c648",  # Laptop
    "/m/050k8",   # Mobile phone
    "/m/02522",   # Computer monitor
    "/m/07c52",   # Television
}


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--annotations", type=Path, required=True)
    parser.add_argument("--split", choices=("validation", "test"), required=True)
    parser.add_argument("--exclude-root", type=Path, required=True)
    parser.add_argument("--output-list", type=Path, required=True)
    parser.add_argument("--target-count", type=int, required=True)
    parser.add_argument("--min-box-area", type=float, default=0.05)
    args = parser.parse_args()

    labels: dict[str, set[str]] = defaultdict(set)
    tablet_area: dict[str, float] = defaultdict(float)
    with args.annotations.open(newline="", encoding="utf-8-sig") as handle:
        reader = csv.DictReader(handle)
        for row in reader:
            image_id = row["ImageID"].lower()
            label = row["LabelName"]
            if label not in OTHER_TARGET_MIDS and label != TABLET_MID:
                continue
            labels[image_id].add(label)
            if label == TABLET_MID and row.get("IsDepiction", "0") == "0" and row.get("IsGroupOf", "0") == "0":
                area = (float(row["XMax"]) - float(row["XMin"])) * (float(row["YMax"]) - float(row["YMin"]))
                tablet_area[image_id] = max(tablet_area[image_id], area)

    existing = {
        path.stem.lower()
        for path in (args.exclude_root / args.split).glob("*/*.jpg")
    }
    eligible = sorted(
        image_id
        for image_id, area in tablet_area.items()
        if area >= args.min_box_area
        and not (labels[image_id] & OTHER_TARGET_MIDS)
        and image_id not in existing
    )
    selected = eligible[: args.target_count]
    args.output_list.parent.mkdir(parents=True, exist_ok=True)
    args.output_list.write_text(
        "".join(f"{args.split}/{image_id}\n" for image_id in selected), encoding="utf-8"
    )
    report = {
        "source": str(args.annotations),
        "split": args.split,
        "tablet_mid": TABLET_MID,
        "minimum_box_area": args.min_box_area,
        "excluded_existing_ids": len(existing),
        "eligible": len(eligible),
        "requested": args.target_count,
        "selected": len(selected),
        "selection": selected,
    }
    args.output_list.with_suffix(".json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({key: report[key] for key in ("split", "eligible", "requested", "selected")}, indent=2))


if __name__ == "__main__":
    main()
