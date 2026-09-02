"""Choose a conservative selective-classification threshold on a fixed test set."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np
import tensorflow as tf
from PIL import Image


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", type=Path, required=True)
    parser.add_argument("--test-root", type=Path, required=True)
    parser.add_argument("--classes", nargs="+", required=True)
    parser.add_argument("--minimum-threshold", type=float, default=0.85)
    parser.add_argument("--target-precision", type=float, default=0.90)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    interpreter = tf.lite.Interpreter(model_path=str(args.model))
    interpreter.allocate_tensors()
    input_info = interpreter.get_input_details()[0]
    output_info = interpreter.get_output_details()[0]
    height, width = map(int, input_info["shape"][1:3])
    rows = []
    for label_index, class_name in enumerate(args.classes):
        for path in sorted((args.test_root / class_name).glob("*.jpg")):
            with Image.open(path) as image:
                image = image.convert("RGB").resize((width, height), Image.Resampling.BILINEAR)
                values = np.asarray(image, dtype=input_info["dtype"])[None, ...]
            interpreter.set_tensor(input_info["index"], values)
            interpreter.invoke()
            probabilities = interpreter.get_tensor(output_info["index"])[0]
            predicted = int(np.argmax(probabilities))
            rows.append({
                "image": path.name,
                "actual": class_name,
                "predicted": args.classes[predicted],
                "confidence": float(probabilities[predicted]),
                "correct": predicted == label_index,
            })

    confidences = sorted({row["confidence"] for row in rows if row["confidence"] >= args.minimum_threshold})
    candidates = []
    for threshold in confidences:
        accepted = [row for row in rows if row["confidence"] >= threshold]
        precision = sum(row["correct"] for row in accepted) / len(accepted)
        if precision >= args.target_precision:
            candidates.append((len(accepted), threshold, precision))
    if not candidates:
        raise SystemExit("No threshold satisfies the requested confident-bucket precision")
    accepted_count, threshold, precision = max(candidates, key=lambda value: (value[0], -value[1]))
    accepted = [row for row in rows if row["confidence"] >= threshold]
    per_class = {}
    for class_name in args.classes:
        class_rows = [row for row in rows if row["actual"] == class_name]
        class_accepted = [row for row in class_rows if row["confidence"] >= threshold]
        per_class[class_name] = {
            "total": len(class_rows),
            "confident": len(class_accepted),
            "coverage": len(class_accepted) / len(class_rows),
            "confident_precision": (
                sum(row["correct"] for row in class_accepted) / len(class_accepted)
                if class_accepted else None
            ),
        }
    report = {
        "model": str(args.model),
        "test_root": str(args.test_root),
        "classes": args.classes,
        "selection_rule": "maximum coverage at or above minimum threshold while confident-bucket accuracy is at least target precision",
        "minimum_threshold_considered": args.minimum_threshold,
        "target_confident_precision": args.target_precision,
        "chosen_threshold": threshold,
        "total": len(rows),
        "confident": accepted_count,
        "unclassified": len(rows) - accepted_count,
        "confident_percent": 100 * accepted_count / len(rows),
        "unclassified_percent": 100 * (len(rows) - accepted_count) / len(rows),
        "confident_precision": precision,
        "confident_correct": sum(row["correct"] for row in accepted),
        "confident_incorrect": sum(not row["correct"] for row in accepted),
        "per_class": per_class,
        "predictions": rows,
        "limitations": [
            "The threshold was selected on this fixed test set and therefore needs a fresh post-launch audit.",
            "Known-safe means the image resembles one of four ordinary device classes; it is not proof that the room is safe.",
            "Low confidence routes to heuristics and sensors rather than being treated as an error.",
        ],
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({key: report[key] for key in (
        "chosen_threshold", "total", "confident", "unclassified",
        "confident_percent", "unclassified_percent", "confident_precision",
        "confident_correct", "confident_incorrect", "per_class",
    )}, indent=2))


if __name__ == "__main__":
    main()
