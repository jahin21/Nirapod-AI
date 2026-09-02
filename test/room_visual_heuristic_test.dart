import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:nirapod_ai/services/room_visual_heuristic.dart';

Uint8List _encoded(img.Image image) => Uint8List.fromList(img.encodePng(image));

void main() {
  test('ordinary uniform frame does not create a Stage B hit', () {
    final frame = img.Image(width: 80, height: 80)..clear(img.ColorRgb8(120, 120, 120));
    expect(RoomVisualHeuristic.analyze(_encoded(frame)).positive, isFalse);
  });

  test('multiple compact neutral highlights create supporting evidence', () {
    final frame = img.Image(width: 80, height: 80)..clear(img.ColorRgb8(90, 90, 90));
    for (final origin in const [(10, 10), (35, 25), (60, 55)]) {
      img.fillRect(frame,
          x1: origin.$1, y1: origin.$2, x2: origin.$1 + 2, y2: origin.$2 + 2,
          color: img.ColorRgb8(250, 250, 250));
    }
    final result = RoomVisualHeuristic.analyze(_encoded(frame));
    expect(result.reflectionCandidates, greaterThanOrEqualTo(3));
    expect(result.positive, isTrue);
  });
}
