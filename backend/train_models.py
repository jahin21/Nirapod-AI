"""Offline, reproducible candidate-model training for Nirapod AI.

This script never runs from FastAPI startup and never promotes a model by
itself. It requires locally reviewed datasets with provenance in
datasets/sources.json.
"""

from __future__ import annotations

import csv
import hashlib
import json
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urlparse

import joblib
import numpy as np
from sklearn.calibration import CalibratedClassifierCV
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.model_selection import GroupShuffleSplit, train_test_split
from sklearn.pipeline import FeatureUnion, Pipeline

from ml_models import DetectionModels, url_features

ROOT = Path(__file__).resolve().parent
DATASETS = ROOT / "datasets"
RAW = DATASETS / "raw"
CANDIDATE = ROOT / "models" / "candidate"
SEED = 42


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def deduplicate(rows: list[tuple[str, int]]) -> tuple[list[tuple[str, int]], int]:
    labels: dict[str, set[int]] = {}
    original: dict[str, str] = {}
    for text, label in rows:
        key = " ".join(text.lower().split())
        if not key:
            continue
        labels.setdefault(key, set()).add(label)
        original.setdefault(key, text.strip())
    clean = [(original[key], next(iter(values))) for key, values in labels.items() if len(values) == 1]
    conflicts = sum(1 for values in labels.values() if len(values) > 1)
    return clean, conflicts


def load_urls(path: Path) -> list[tuple[str, int]]:
    rows: list[tuple[str, int]] = []
    with path.open(encoding="utf-8", errors="replace", newline="") as stream:
        reader = csv.DictReader(stream)
        if not reader.fieldnames or not {"URL", "label"}.issubset(reader.fieldnames):
            raise ValueError("PhiUSIIL CSV must contain URL and label columns")
        for row in reader:
            url = (row.get("URL") or "").strip()
            source_label = int(row["label"])
            if url:
                rows.append((url, 1 if source_label == 0 else 0))
    return rows


def load_messages(path: Path) -> list[tuple[str, int]]:
    rows: list[tuple[str, int]] = []
    with path.open(encoding="utf-8", errors="replace") as stream:
        for line in stream:
            label, separator, text = line.rstrip("\n").partition("\t")
            if separator and label in {"ham", "spam"} and text.strip():
                rows.append((text.strip(), int(label == "spam")))
    return rows


def url_group(value: str) -> str:
    host = (urlparse(value if "://" in value else f"https://{value}").hostname or "").lower()
    parts = host.strip(".").split(".")
    return ".".join(parts[-2:]) if len(parts) >= 2 else host


def metrics(y_true, y_probability, threshold: float = 0.5) -> dict:
    y_pred = (np.asarray(y_probability) >= threshold).astype(int)
    report = classification_report(y_true, y_pred, output_dict=True, zero_division=0)
    return {
        "accuracy": report["accuracy"],
        "precision": report["1"]["precision"],
        "recall": report["1"]["recall"],
        "f1": report["1"]["f1-score"],
        "false_positive_rate": float(((y_pred == 1) & (np.asarray(y_true) == 0)).sum() / max(1, (np.asarray(y_true) == 0).sum())),
        "false_negative_rate": float(((y_pred == 0) & (np.asarray(y_true) == 1)).sum() / max(1, (np.asarray(y_true) == 1).sum())),
        "confusion_matrix": confusion_matrix(y_true, y_pred, labels=[0, 1]).tolist(),
        "samples": len(y_true),
    }


def train_url(rows: list[tuple[str, int]]):
    texts = np.asarray([row[0] for row in rows])
    labels = np.asarray([row[1] for row in rows])
    groups = np.asarray([url_group(value) for value in texts])
    outer = GroupShuffleSplit(n_splits=1, test_size=0.2, random_state=SEED)
    train_index, test_index = next(outer.split(texts, labels, groups))
    base = LogisticRegression(max_iter=1500, class_weight="balanced", random_state=SEED)
    model = CalibratedClassifierCV(base, method="sigmoid", cv=5)
    model.fit([url_features(value) for value in texts[train_index]], labels[train_index])
    probability = model.predict_proba([url_features(value) for value in texts[test_index]])[:, 1]
    return model, metrics(labels[test_index], probability), (
        texts[test_index],
        labels[test_index],
    )


def train_message(rows: list[tuple[str, int]]):
    texts = np.asarray([row[0] for row in rows])
    labels = np.asarray([row[1] for row in rows])
    train_text, test_text, train_y, test_y = train_test_split(
        texts, labels, test_size=0.2, random_state=SEED, stratify=labels
    )
    features = FeatureUnion([
        ("word", TfidfVectorizer(ngram_range=(1, 2), min_df=2, sublinear_tf=True)),
        ("char", TfidfVectorizer(analyzer="char_wb", ngram_range=(3, 5), min_df=2, sublinear_tf=True)),
    ])
    model = Pipeline([
        ("features", features),
        ("classifier", LogisticRegression(max_iter=1500, class_weight="balanced", random_state=SEED)),
    ])
    model.fit(train_text, train_y)
    probability = model.predict_proba(test_text)[:, 1]
    return model, metrics(test_y, probability), (test_text, test_y)


def main() -> None:
    url_path = RAW / "PhiUSIIL_Phishing_URL_Dataset.csv"
    message_path = RAW / "SMSSpamCollection"
    missing = [str(path) for path in (url_path, message_path) if not path.exists()]
    if missing:
        raise SystemExit("Missing offline datasets:\n- " + "\n- ".join(missing))

    urls, url_conflicts = deduplicate(load_urls(url_path))
    messages, message_conflicts = deduplicate(load_messages(message_path))
    if len(urls) < 1000 or len(messages) < 1000:
        raise SystemExit("Dataset validation failed: too few usable labelled samples")

    url_model, url_metrics, url_holdout = train_url(urls)
    message_model, message_metrics, message_holdout = train_message(messages)
    baseline = DetectionModels()
    baseline_url_probability = baseline.url_model.predict_proba(
        [url_features(value) for value in url_holdout[0]]
    )[:, 1]
    baseline_message_probability = baseline.message_model.predict_proba(
        message_holdout[0]
    )[:, 1]
    baseline_metrics = {
        "url": metrics(url_holdout[1], baseline_url_probability),
        "message": metrics(message_holdout[1], baseline_message_probability),
    }
    CANDIDATE.mkdir(parents=True, exist_ok=True)
    joblib.dump(url_model, CANDIDATE / "url_model.joblib")
    joblib.dump(message_model, CANDIDATE / "message_model.joblib")
    manifest = {
        "schema_version": 1,
        "status": "candidate",
        "model_version": datetime.now(timezone.utc).strftime("candidate-%Y%m%dT%H%M%SZ"),
        "created_at": datetime.now(timezone.utc).isoformat(),
        "random_seed": SEED,
        "datasets": {
            "url": {"sha256": sha256(url_path), "rows": len(urls), "conflicts_removed": url_conflicts, "class_counts": Counter(label for _, label in urls)},
            "message": {"sha256": sha256(message_path), "rows": len(messages), "conflicts_removed": message_conflicts, "class_counts": Counter(label for _, label in messages)},
        },
        "metrics": {
            "candidate": {"url": url_metrics, "message": message_metrics},
            "embedded_baseline": baseline_metrics,
        },
        "artifacts": {"url_model": "candidate/url_model.joblib", "message_model": "candidate/message_model.joblib"},
        "limitations": [
            "SMS Spam Collection evaluates English spam versus ham, not all scam or phishing categories.",
            "No Bangla or Bahasa Melayu claim is valid until separately licensed native-language holdouts are evaluated.",
        ],
    }
    (CANDIDATE / "candidate_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2, default=dict), encoding="utf-8"
    )
    print(json.dumps(manifest["metrics"], indent=2))
    print("Candidate artifacts created but NOT promoted.")


if __name__ == "__main__":
    main()
