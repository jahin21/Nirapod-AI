"""Pure, conservative evidence fusion for the room safety workflow."""

from __future__ import annotations

from dataclasses import asdict, dataclass


@dataclass(frozen=True)
class SignalEvidence:
    signal_type: str
    label: str
    detected: bool
    confidence: float
    limitation: str
    evidence: str
    independent_group: str
    high_confidence_decisive: bool = False

    def public(self) -> dict:
        value = asdict(self)
        value.pop("independent_group")
        value["confidence"] = round(max(0.0, min(1.0, self.confidence)), 4)
        return value


def fuse_room_evidence(signals: list[SignalEvidence], checks_completed: int) -> dict:
    """Return a four-class result without treating one ordinary hit as proof."""
    positives = [signal for signal in signals if signal.detected]
    groups = {signal.independent_group for signal in positives}
    decisive = [signal for signal in positives if signal.high_confidence_decisive]

    if decisive:
        classification, risk_score = "dangerous", 82
        confidence = max(signal.confidence for signal in decisive)
        summary = "A validated specialist signal met the high-confidence escalation criteria."
    elif len(groups) >= 2:
        classification, risk_score = "dangerous", 76
        confidence = min(0.90, 0.62 + 0.08 * len(groups))
        summary = "Two or more independent evidence types agreed."
    elif positives:
        classification, risk_score = "suspicious", 46
        confidence = max(0.50, min(0.78, max(signal.confidence for signal in positives)))
        summary = "One supporting signal was observed; it is not conclusive by itself."
    elif checks_completed > 0:
        classification, risk_score, confidence = "safe", 12, 0.78
        summary = "No indicators were reported by the checks that were completed."
    else:
        classification, risk_score, confidence = "inconclusive", 0, 0.0
        summary = "No supported inspection step was completed."

    return {
        "classification": classification,
        "risk_score": risk_score,
        "confidence": round(confidence, 4),
        "summary": summary,
        "signals": [signal.public() for signal in signals],
    }

