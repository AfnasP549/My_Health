// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../domain/entities/health_data.dart';

class HeartRatePainter extends CustomPainter {
  final List<HrRaw> heartRates;
  final DateTime windowStart;
  final DateTime windowEnd;

  HeartRatePainter({
    required this.heartRates,
    required this.windowStart,
    required this.windowEnd,
  });

  static final Paint _linePaint = Paint()
    ..color = Colors.red
    ..strokeWidth = 2.0
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  static final Paint _areaPaint = Paint()
    ..color = Colors.red.withOpacity(0.1)
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (heartRates.isEmpty) return;

    final double width = size.width;
    final double height = size.height;
    final double totalTimeMs = windowEnd
        .difference(windowStart)
        .inMilliseconds
        .toDouble();

    // Standard BPM scaling (40bpm to 200bpm or auto-scale)
    int maxHr = 150;
    int minHr = 60;
    for (int i = 0; i < heartRates.length; i++) {
      if (heartRates[i].bpm > maxHr) maxHr = heartRates[i].bpm;
      if (heartRates[i].bpm < minHr) minHr = heartRates[i].bpm;
    }

    final double hrRange = (maxHr - minHr).toDouble().clamp(20.0, 500.0);
    final double yScale = height / hrRange;

    // Use a fresh path each frame (Paths can be heavy if reused incorrectly across frames)
    final Path path = Path();
    bool first = true;

    for (int i = 0; i < heartRates.length; i++) {
      final hr = heartRates[i];
      final msOffset = hr.timestamp.difference(windowStart).inMilliseconds;

      if (msOffset < 0 || msOffset > totalTimeMs) continue;

      final x = (msOffset / totalTimeMs) * width;
      final y = height - ((hr.bpm - minHr) * yScale);

      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }

    if (!first) {
      // Line
      canvas.drawPath(path, _linePaint);

      // Fill below
      final Path fillPath = Path.from(path);
      fillPath.lineTo(width, height);
      fillPath.lineTo(0, height);
      fillPath.close();
      canvas.drawPath(fillPath, _areaPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HeartRatePainter oldDelegate) {
    return oldDelegate.heartRates != heartRates ||
        oldDelegate.windowStart != windowStart ||
        oldDelegate.windowEnd != windowEnd;
  }
}
