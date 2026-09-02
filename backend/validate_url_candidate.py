"""Independent URL candidate validation. Never promotes a model."""

from __future__ import annotations

import csv
import gzip
import json
import statistics
import time
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urlparse

import joblib
import numpy as np
from sklearn.metrics import (
    average_precision_score,
    classification_report,
    confusion_matrix,
)

from ml_models import DetectionModels, normalize_url, url_features

ROOT = Path(__file__).resolve().parent
RAW = ROOT / "datasets" / "raw" / "PhiUSIIL_Phishing_URL_Dataset.csv"
VALIDATION = ROOT / "datasets" / "validation"
CANDIDATE_PATH = ROOT / "models" / "candidate" / "url_model.joblib"
REPORT_PATH = ROOT / "models" / "candidate" / "url_external_validation.json"
MAX_PER_CLASS = 5000
THRESHOLD = 0.5


def domain(value: str) -> str:
    parsed = urlparse(normalize_url(value))
    host = (parsed.hostname or "").lower().strip(".")
    parts = host.split(".")
    if len(parts) <= 2:
        return host
    if len(parts[-1]) == 2 and parts[-2] in {"com", "net", "org", "edu", "gov"}:
        return ".".join(parts[-3:])
    return ".".join(parts[-2:])


def training_domains() -> set[str]:
    result: set[str] = set()
    with RAW.open(encoding="utf-8", errors="replace", newline="") as stream:
        for row in csv.DictReader(stream):
            value = row.get("URL", "")
            if value:
                result.add(domain(value))
    return result


def phishing_urls(excluded: set[str]) -> list[str]:
    plain = VALIDATION / "online-valid.csv"
    compressed = VALIDATION / "online-valid.csv.gz"
    community = VALIDATION / "openphish-feed.txt"
    if not plain.exists() and not compressed.exists() and community.exists():
        result = []
        with community.open(encoding="utf-8", errors="replace") as stream:
            for line in stream:
                value = line.strip()
                if value and domain(value) not in excluded:
                    result.append(value)
                    if len(result) >= MAX_PER_CLASS:
                        break
        return result
    opener = (
        gzip.open(compressed, mode="rt", encoding="utf-8", errors="replace")
        if compressed.exists()
        else plain.open(encoding="utf-8", errors="replace")
    )
    result: list[str] = []
    with opener as stream:
        for row in csv.DictReader(stream):
            value = (row.get("url") or "").strip()
            if (
                value
                and row.get("verified", "").lower() == "yes"
                and row.get("online", "").lower() == "yes"
                and domain(value) not in excluded
            ):
                result.append(value)
                if len(result) >= MAX_PER_CLASS:
                    break
    return result


def legitimate_urls(excluded: set[str]) -> list[str]:
    path = VALIDATION / "top-1m.csv"
    result: list[str] = []
    with path.open(encoding="utf-8", errors="replace", newline="") as stream:
        for row in csv.reader(stream):
            if len(row) < 2:
                continue
            candidate = f"https://{row[1].strip()}/"
            if domain(candidate) not in excluded:
                result.append(candidate)
                if len(result) >= MAX_PER_CLASS:
                    break
    return result


def expected_calibration_error(labels, probabilities, bins: int = 10) -> float:
    labels = np.asarray(labels)
    probabilities = np.asarray(probabilities)
    error = 0.0
    edges = np.linspace(0.0, 1.0, bins + 1)
    for index in range(bins):
        mask = (probabilities >= edges[index]) & (
            probabilities <= edges[index + 1]
            if index == bins - 1
            else probabilities < edges[index + 1]
        )
        if mask.any():
            error += mask.mean() * abs(labels[mask].mean() - probabilities[mask].mean())
    return float(error)


def evaluate(model, values, labels) -> dict:
    features = [url_features(value) for value in values]
    probabilities = model.predict_proba(features)[:, 1]
    predictions = (probabilities >= THRESHOLD).astype(int)
    report = classification_report(labels, predictions, output_dict=True, zero_division=0)
    timings = []
    for feature in features[:1000]:
        started = time.perf_counter()
        model.predict_proba([feature])
        timings.append((time.perf_counter() - started) * 1000)
    negatives = np.asarray(labels) == 0
    positives = np.asarray(labels) == 1
    return {
        "accuracy": report["accuracy"],
        "precision": report["1"]["precision"],
        "recall": report["1"]["recall"],
        "f1": report["1"]["f1-score"],
        "pr_auc": float(average_precision_score(labels, probabilities)),
        "false_positive_rate": float(((predictions == 1) & negatives).sum() / max(1, negatives.sum())),
        "false_negative_rate": float(((predictions == 0) & positives).sum() / max(1, positives.sum())),
        "calibration_error": expected_calibration_error(labels, probabilities),
        "latency_ms_average": statistics.mean(timings),
        "latency_ms_p95": float(np.percentile(timings, 95)),
        "confusion_matrix": confusion_matrix(labels, predictions, labels=[0, 1]).tolist(),
        "samples": len(labels),
    }


def scenarios(candidate_model) -> list[dict]:
    baseline = DetectionModels()
    candidate = DetectionModels()
    candidate.url_model = candidate_model
    candidate.model_version = "candidate-external-validation"
    cases = [
        ("shortener", "https://bit.ly/account-review", {"suspicious", "dangerous"}),
        ("punycode", "https://xn--microsft-5za.example/login", {"dangerous"}),
        ("brand impersonation", "https://paypa1-secure.example.com/login", {"dangerous"}),
        ("IP destination", "http://185.199.110.153/verify", {"dangerous"}),
        ("malformed", "not a valid destination", {"dangerous", "inconclusive"}),
        ("redirect parameter", "https://example.com/redirect?url=http://185.199.110.153/login", {"suspicious", "dangerous"}),
        ("known official", "https://www.google.com/", {"safe"}),
    ]
    results = []
    for category, value, expected in cases:
        baseline_result = baseline.predict_url(value)
        candidate_result = candidate.predict_url(value)
        results.append({
            "category": category,
            "url": value,
            "expected": sorted(expected),
            "baseline": baseline_result[0],
            "candidate": candidate_result[0],
            "candidate_pass": candidate_result[0] in expected,
        })
    return results


def main() -> None:
    required = [
        RAW,
        CANDIDATE_PATH,
        VALIDATION / "top-1m.csv",
    ]
    if not any(
        (VALIDATION / name).exists()
        for name in ("online-valid.csv", "online-valid.csv.gz", "openphish-feed.txt")
    ):
        required.append(VALIDATION / "online-valid.csv.gz")
    missing = [str(path) for path in required if not path.exists()]
    if missing:
        raise SystemExit("Missing validation inputs:\n- " + "\n- ".join(missing))

    excluded = training_domains()
    phishing = phishing_urls(excluded)
    legitimate = legitimate_urls(excluded)
    sample_size = min(len(phishing), len(legitimate), MAX_PER_CLASS)
    if sample_size < 100:
        raise SystemExit("Independent validation requires at least 100 samples per class")
    phishing = phishing[:sample_size]
    legitimate = legitimate[:sample_size]
    values = legitimate + phishing
    labels = np.asarray([0] * len(legitimate) + [1] * len(phishing))
    candidate = joblib.load(CANDIDATE_PATH)
    baseline = DetectionModels().url_model
    candidate_metrics = evaluate(candidate, values, labels)
    baseline_metrics = evaluate(baseline, values, labels)
    scenario_results = scenarios(candidate)
    gates = {
        "f1_improvement_at_least_0_05": candidate_metrics["f1"] >= baseline_metrics["f1"] + 0.05,
        "recall_improved": candidate_metrics["recall"] > baseline_metrics["recall"],
        "false_positive_rate_at_most_0_02": candidate_metrics["false_positive_rate"] <= 0.02,
        "calibration_error_at_most_0_10": candidate_metrics["calibration_error"] <= 0.10,
        "p95_latency_at_most_10ms": candidate_metrics["latency_ms_p95"] <= 10.0,
        "all_scenarios_pass": all(item["candidate_pass"] for item in scenario_results),
    }
    phishing_source = (
        "PhishTank online-valid verified feed"
        if any(
            (VALIDATION / name).exists()
            for name in ("online-valid.csv", "online-valid.csv.gz")
        )
        else "OpenPhish Community Feed"
    )
    report = {
        "created_at": datetime.now(timezone.utc).isoformat(),
        "status": "eligible_for_manual_promotion" if all(gates.values()) else "not_eligible",
        "dataset": {
            "phishing_source": phishing_source,
            "legitimate_source": "Tranco latest standard list",
            "training_domains_excluded": len(excluded),
            "phishing_samples": len(phishing),
            "legitimate_samples": len(legitimate),
        },
        "candidate": candidate_metrics,
        "embedded_baseline": baseline_metrics,
        "gates": gates,
        "scenario_tests": scenario_results,
        "artifact_bytes": CANDIDATE_PATH.stat().st_size,
        "limitations": [
            "Tranco popularity is a benign proxy and cannot guarantee every page is safe.",
            "PhishTank represents currently online verified reports and is not every possible phishing campaign.",
            "DNS and threat-list behaviour is checked separately from these offline model metrics.",
        ],
    }
    REPORT_PATH.write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(json.dumps(report, indent=2))
    if report["status"] != "eligible_for_manual_promotion":
        raise SystemExit(2)


if __name__ == "__main__":
    main()
