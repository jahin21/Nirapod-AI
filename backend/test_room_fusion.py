import unittest

from room_fusion import SignalEvidence, fuse_room_evidence


LIMIT = "This signal is supporting evidence and is not conclusive by itself."


def signal(name, confidence, group, decisive=False):
    return SignalEvidence(name, name, True, confidence, LIMIT, "test", group, decisive)


class RoomFusionTest(unittest.TestCase):
    def test_single_visual_signal_is_caution(self):
        result = fuse_room_evidence([signal("visual", 0.55, "visual")], 1)
        self.assertEqual(result["classification"], "suspicious")
        self.assertLess(result["risk_score"], 60)

    def test_single_bluetooth_signal_is_caution(self):
        result = fuse_room_evidence([signal("bluetooth", 0.35, "bluetooth")], 1)
        self.assertEqual(result["classification"], "suspicious")

    def test_visual_and_rf_are_dangerous(self):
        result = fuse_room_evidence([
            signal("visual", 0.55, "visual"),
            signal("rf", 0.76, "directional_rf"),
        ], 2)
        self.assertEqual(result["classification"], "dangerous")

    def test_validated_high_confidence_thermal_can_be_dangerous(self):
        result = fuse_room_evidence([signal("thermal", 0.94, "thermal", True)], 1)
        self.assertEqual(result["classification"], "dangerous")

    def test_unvalidated_thermal_is_only_caution(self):
        result = fuse_room_evidence([signal("thermal", 0.94, "thermal")], 1)
        self.assertEqual(result["classification"], "suspicious")

    def test_no_completed_check_is_inconclusive(self):
        result = fuse_room_evidence([], 0)
        self.assertEqual(result["classification"], "inconclusive")


if __name__ == "__main__":
    unittest.main()
