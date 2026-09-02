"""Train and calibrate the five-class Stage A room-object candidate.

This is an offline-only candidate pipeline. It preserves the official Open
Images splits, never reads ``_deferred``, and never promotes its artifacts into
the Flutter application or FastAPI production model directory.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import random
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

os.environ.setdefault("TF_CPP_MIN_LOG_LEVEL", "2")

import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf
from sklearn.metrics import classification_report, confusion_matrix


SEED = 42
EXPECTED_CLASSES = ["laptop", "monitor", "phone", "tablet", "tv_monitor"]


def set_reproducible() -> None:
    random.seed(SEED)
    np.random.seed(SEED)
    tf.random.set_seed(SEED)
    try:
        tf.config.experimental.enable_op_determinism()
    except Exception:
        pass


def count_images(root: Path) -> dict[str, int]:
    return {
        class_name: len(list((root / class_name).glob("*.jpg")))
        for class_name in EXPECTED_CLASSES
    }


def dataset_fingerprint(root: Path) -> str:
    digest = hashlib.sha256()
    for split in ("train", "validation", "test"):
        for class_name in EXPECTED_CLASSES:
            for path in sorted((root / split / class_name).glob("*.jpg")):
                digest.update(f"{split}/{class_name}/{path.name}\n".encode())
                digest.update(hashlib.sha256(path.read_bytes()).digest())
    return digest.hexdigest()


def load_dataset(path: Path, image_size: int, batch_size: int, shuffle: bool):
    return tf.keras.utils.image_dataset_from_directory(
        path,
        labels="inferred",
        label_mode="int",
        class_names=EXPECTED_CLASSES,
        image_size=(image_size, image_size),
        batch_size=batch_size,
        shuffle=shuffle,
        seed=SEED if shuffle else None,
    ).prefetch(tf.data.AUTOTUNE)


def collect_logits(model, dataset) -> tuple[np.ndarray, np.ndarray]:
    logits, labels = [], []
    for images, batch_labels in dataset:
        logits.append(model(images, training=False).numpy())
        labels.append(batch_labels.numpy())
    return np.concatenate(logits), np.concatenate(labels)


def softmax(logits: np.ndarray, temperature: float) -> np.ndarray:
    scaled = logits / temperature
    scaled -= scaled.max(axis=1, keepdims=True)
    values = np.exp(scaled)
    return values / values.sum(axis=1, keepdims=True)


def nll(probabilities: np.ndarray, labels: np.ndarray) -> float:
    chosen = probabilities[np.arange(len(labels)), labels]
    return float(-np.log(np.clip(chosen, 1e-9, 1.0)).mean())


def choose_temperature(logits: np.ndarray, labels: np.ndarray) -> float:
    candidates = np.geomspace(0.25, 5.0, 500)
    losses = [nll(softmax(logits, value), labels) for value in candidates]
    return float(candidates[int(np.argmin(losses))])


def calibration(probabilities: np.ndarray, labels: np.ndarray, bins: int = 10) -> dict:
    confidence = probabilities.max(axis=1)
    predicted = probabilities.argmax(axis=1)
    correct = predicted == labels
    edges = np.linspace(0, 1, bins + 1)
    rows = []
    ece = 0.0
    for index in range(bins):
        lower, upper = edges[index], edges[index + 1]
        mask = (confidence >= lower) & (confidence < upper if index < bins - 1 else confidence <= upper)
        if not mask.any():
            rows.append({"lower": lower, "upper": upper, "count": 0, "confidence": None, "accuracy": None})
            continue
        bin_confidence = float(confidence[mask].mean())
        bin_accuracy = float(correct[mask].mean())
        ece += float(mask.mean()) * abs(bin_accuracy - bin_confidence)
        rows.append({"lower": lower, "upper": upper, "count": int(mask.sum()), "confidence": bin_confidence, "accuracy": bin_accuracy})
    return {"ece": ece, "bins": rows}


def plot_reliability(before: dict, after: dict, output: Path) -> None:
    figure, axis = plt.subplots(figsize=(7, 7))
    axis.plot([0, 1], [0, 1], "--", color="gray", label="Perfect calibration")
    for label, result, marker in (("Before", before, "o"), ("After temperature scaling", after, "s")):
        points = [(row["confidence"], row["accuracy"]) for row in result["bins"] if row["count"]]
        axis.plot([x for x, _ in points], [y for _, y in points], marker=marker, label=f"{label} (ECE={result['ece']:.3f})")
    axis.set(xlabel="Mean predicted confidence", ylabel="Observed accuracy", title="Stage A validation reliability")
    axis.set_xlim(0, 1)
    axis.set_ylim(0, 1)
    axis.grid(alpha=0.25)
    axis.legend()
    figure.tight_layout()
    figure.savefig(output, dpi=180)
    plt.close(figure)


def main() -> None:
    global EXPECTED_CLASSES
    parser = argparse.ArgumentParser()
    parser.add_argument("--data-root", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--classes", nargs="+", default=EXPECTED_CLASSES)
    parser.add_argument("--head-epochs", type=int, default=8)
    parser.add_argument("--fine-tune-epochs", type=int, default=12)
    parser.add_argument("--fine-tune-layers", type=int, default=40)
    parser.add_argument("--fine-tune-learning-rate", type=float, default=1e-5)
    parser.add_argument("--image-size", type=int, default=224)
    parser.add_argument("--batch-size", type=int, default=32)
    args = parser.parse_args()
    EXPECTED_CLASSES = args.classes
    set_reproducible()

    counts = {split: count_images(args.data_root / split) for split in ("train", "validation", "test")}
    for split, split_counts in counts.items():
        if any(value == 0 for value in split_counts.values()):
            raise SystemExit(f"Missing Stage A class data in {split}: {split_counts}")
    if (args.data_root / "train" / "smart_speaker").exists():
        raise SystemExit("smart_speaker must be deferred before Stage A v1")

    train = load_dataset(args.data_root / "train", args.image_size, args.batch_size, True)
    validation = load_dataset(args.data_root / "validation", args.image_size, args.batch_size, False)
    test = load_dataset(args.data_root / "test", args.image_size, args.batch_size, False)

    augmentation = tf.keras.Sequential([
        tf.keras.layers.RandomFlip("horizontal", seed=SEED),
        tf.keras.layers.RandomRotation(0.04, seed=SEED),
        tf.keras.layers.RandomZoom(0.1, seed=SEED),
        tf.keras.layers.RandomContrast(0.1, seed=SEED),
    ], name="training_only_augmentation")
    inputs = tf.keras.Input(shape=(args.image_size, args.image_size, 3), name="image")
    values = augmentation(inputs)
    values = tf.keras.layers.Rescaling(1 / 127.5, offset=-1, name="mobilenet_preprocess")(values)
    backbone = tf.keras.applications.MobileNetV2(
        input_shape=(args.image_size, args.image_size, 3), include_top=False, weights="imagenet"
    )
    backbone.trainable = False
    values = backbone(values, training=False)
    values = tf.keras.layers.GlobalAveragePooling2D()(values)
    values = tf.keras.layers.Dropout(0.25, seed=SEED)(values)
    logits = tf.keras.layers.Dense(len(EXPECTED_CLASSES), name="logits")(values)
    model = tf.keras.Model(inputs, logits, name="nirapod_stage_a_v1")
    model.compile(
        optimizer=tf.keras.optimizers.Adam(1e-3),
        loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
        metrics=["accuracy"],
    )
    total = sum(counts["train"].values())
    class_weights = {
        index: total / (len(EXPECTED_CLASSES) * counts["train"][name])
        for index, name in enumerate(EXPECTED_CLASSES)
    }
    head_callbacks = [
        tf.keras.callbacks.EarlyStopping(monitor="val_loss", patience=3, restore_best_weights=True),
        tf.keras.callbacks.ReduceLROnPlateau(monitor="val_loss", patience=2, factor=0.3),
    ]
    head_history = model.fit(
        train,
        validation_data=validation,
        epochs=args.head_epochs,
        class_weight=class_weights,
        callbacks=head_callbacks,
    )

    backbone.trainable = True
    fine_tune_from = max(0, len(backbone.layers) - args.fine_tune_layers)
    for index, layer in enumerate(backbone.layers):
        layer.trainable = index >= fine_tune_from and not isinstance(layer, tf.keras.layers.BatchNormalization)
    model.compile(
        optimizer=tf.keras.optimizers.Adam(args.fine_tune_learning_rate),
        loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
        metrics=["accuracy"],
    )
    fine_callbacks = [
        tf.keras.callbacks.EarlyStopping(monitor="val_loss", patience=4, restore_best_weights=True),
        tf.keras.callbacks.ReduceLROnPlateau(monitor="val_loss", patience=2, factor=0.3, min_lr=1e-7),
    ]
    fine_history = model.fit(
        train,
        validation_data=validation,
        epochs=args.fine_tune_epochs,
        class_weight=class_weights,
        callbacks=fine_callbacks,
    )

    clean_train = load_dataset(args.data_root / "train", args.image_size, args.batch_size, False)
    clean_train_loss, clean_train_accuracy = model.evaluate(clean_train, verbose=0)
    clean_validation_loss, clean_validation_accuracy = model.evaluate(validation, verbose=0)

    validation_logits, validation_labels = collect_logits(model, validation)
    test_logits, test_labels = collect_logits(model, test)
    temperature = choose_temperature(validation_logits, validation_labels)
    validation_before = calibration(softmax(validation_logits, 1.0), validation_labels)
    validation_after = calibration(softmax(validation_logits, temperature), validation_labels)
    test_probabilities = softmax(test_logits, temperature)
    test_predictions = test_probabilities.argmax(axis=1)
    report = classification_report(test_labels, test_predictions, target_names=EXPECTED_CLASSES, output_dict=True, zero_division=0)

    args.output.mkdir(parents=True, exist_ok=True)
    plot_reliability(validation_before, validation_after, args.output / "reliability_diagram.png")
    (args.output / "labels.txt").write_text("\n".join(EXPECTED_CLASSES) + "\n", encoding="utf-8")

    inference_inputs = tf.keras.Input(shape=(args.image_size, args.image_size, 3), name="image")
    inference_output = tf.keras.layers.Softmax(name="calibrated_probabilities")(model(inference_inputs) / temperature)
    inference_model = tf.keras.Model(inference_inputs, inference_output)
    converter = tf.lite.TFLiteConverter.from_keras_model(inference_model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite = converter.convert()
    (args.output / "room_safe_classifier.tflite").write_bytes(tflite)

    manifest = {
        "status": "candidate_not_promoted",
        "created_at": datetime.now(timezone.utc).isoformat(),
        "classes": EXPECTED_CLASSES,
        "excluded_classes": ["smart_speaker"],
        "counts": counts,
        "dataset_sha256": dataset_fingerprint(args.data_root),
        "seed": SEED,
        "architecture": "MobileNetV2 ImageNet transfer learning with top-layer fine-tuning",
        "pretrained_weights": "ImageNet",
        "image_size": args.image_size,
        "batch_size": args.batch_size,
        "head_learning_rate": 1e-3,
        "fine_tune_learning_rate": args.fine_tune_learning_rate,
        "backbone_layers": len(backbone.layers),
        "fine_tuned_backbone_layers": sum(layer.trainable for layer in backbone.layers),
        "head_epochs_completed": len(head_history.history["loss"]),
        "fine_tune_epochs_completed": len(fine_history.history["loss"]),
        "epochs_completed": len(head_history.history["loss"]) + len(fine_history.history["loss"]),
        "training_accuracy": float(clean_train_accuracy),
        "training_loss": float(clean_train_loss),
        "validation_accuracy": float(clean_validation_accuracy),
        "validation_loss": float(clean_validation_loss),
        "best_validation_accuracy": float(max(head_history.history["val_accuracy"] + fine_history.history["val_accuracy"])),
        "temperature": temperature,
        "validation_calibration": {"before": validation_before, "after": validation_after},
        "test_accuracy": float((test_predictions == test_labels).mean()),
        "test_classification_report": report,
        "test_confusion_matrix": confusion_matrix(test_labels, test_predictions).tolist(),
        "artifact_sha256": hashlib.sha256(tflite).hexdigest(),
        "limitations": [
            "This model classifies five known-safe device categories; it does not detect hidden cameras.",
            "The tablet validation split has only 11 images, so its validation estimate is high-variance.",
            "Image-level Open Images labels may describe small or incidental objects and require manual review.",
            "The candidate has not been integrated into or promoted within the release application.",
        ],
    }
    (args.output / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({key: manifest[key] for key in ("training_accuracy", "validation_accuracy", "best_validation_accuracy", "test_accuracy", "temperature")}, indent=2))
    print("Stage A candidate exported; NOT promoted. Stage B has not started.")


if __name__ == "__main__":
    main()
