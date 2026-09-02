import 'dart:collection';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class RoomVisualHeuristicResult {
  const RoomVisualHeuristicResult({
    required this.reflectionScore,
    required this.pinholeScore,
    required this.reflectionCandidates,
    required this.pinholeCandidates,
  });

  final double reflectionScore;
  final double pinholeScore;
  final int reflectionCandidates;
  final int pinholeCandidates;

  bool get positive => reflectionScore >= 0.72 || pinholeScore >= 0.78;

  Map<String, dynamic> toJson() => {
        'reflection_score': reflectionScore,
        'pinhole_score': pinholeScore,
        'reflection_candidates': reflectionCandidates,
        'pinhole_candidates': pinholeCandidates,
        'positive': positive,
      };
}

class RoomVisualHeuristic {
  const RoomVisualHeuristic._();

  static RoomVisualHeuristicResult analyze(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw const FormatException('Unsupported image');
    final scale = math.min(1.0, 360 / math.max(decoded.width, decoded.height));
    final frame = scale < 1
        ? img.copyResize(
            decoded,
            width: math.max(1, (decoded.width * scale).round()),
            height: math.max(1, (decoded.height * scale).round()),
          )
        : decoded;
    final width = frame.width;
    final height = frame.height;
    final gray = List<int>.filled(width * height, 0);
    final bright = Uint8List(width * height);
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final pixel = frame.getPixel(x, y);
        final r = pixel.r.toInt(), g = pixel.g.toInt(), b = pixel.b.toInt();
        final luminance = (0.299 * r + 0.587 * g + 0.114 * b).round();
        final index = y * width + x;
        gray[index] = luminance;
        final chroma =
            math.max(r, math.max(g, b)) - math.min(r, math.min(g, b));
        if (luminance >= 242 && chroma <= 32) bright[index] = 1;
      }
    }

    final dark = Uint8List(width * height);
    for (var y = 4; y < height - 4; y++) {
      for (var x = 4; x < width - 4; x++) {
        final index = y * width + x;
        if (gray[index] >= 38) continue;
        var surround = 0;
        var samples = 0;
        for (final offset in const [
          [-4, 0],
          [4, 0],
          [0, -4],
          [0, 4],
          [-3, -3],
          [3, -3],
          [-3, 3],
          [3, 3]
        ]) {
          surround += gray[(y + offset[1]) * width + x + offset[0]];
          samples++;
        }
        if (surround / samples >= 72) dark[index] = 1;
      }
    }

    final reflection = _compactComponents(bright, width, height, 2, 220);
    final pinholes = _compactComponents(dark, width, height, 2, 100);
    return RoomVisualHeuristicResult(
      reflectionScore: math.min(1, reflection / 3),
      pinholeScore: math.min(1, pinholes / 2),
      reflectionCandidates: reflection,
      pinholeCandidates: pinholes,
    );
  }

  static int _compactComponents(
    Uint8List mask,
    int width,
    int height,
    int minArea,
    int maxArea,
  ) {
    final seen = Uint8List(mask.length);
    var candidates = 0;
    for (var start = 0; start < mask.length; start++) {
      if (mask[start] == 0 || seen[start] != 0) continue;
      final queue = Queue<int>()..add(start);
      seen[start] = 1;
      var area = 0, minX = width, maxX = 0, minY = height, maxY = 0;
      while (queue.isNotEmpty) {
        final index = queue.removeFirst();
        final x = index % width, y = index ~/ width;
        area++;
        minX = math.min(minX, x);
        maxX = math.max(maxX, x);
        minY = math.min(minY, y);
        maxY = math.max(maxY, y);
        for (final next in [
          index - 1,
          index + 1,
          index - width,
          index + width
        ]) {
          if (next < 0 ||
              next >= mask.length ||
              seen[next] != 0 ||
              mask[next] == 0) {
            continue;
          }
          final nx = next % width;
          if ((nx - x).abs() > 1) {
            continue;
          }
          seen[next] = 1;
          queue.add(next);
        }
      }
      final boxWidth = maxX - minX + 1, boxHeight = maxY - minY + 1;
      final aspect = boxWidth / boxHeight;
      final fill = area / (boxWidth * boxHeight);
      if (area >= minArea &&
          area <= maxArea &&
          aspect >= 0.35 &&
          aspect <= 2.85 &&
          fill >= 0.28) {
        candidates++;
      }
    }
    return candidates;
  }
}
