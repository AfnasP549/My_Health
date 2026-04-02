// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../domain/entities/health_data.dart';

class StepsChartPainter extends CustomPainter {
  final List<StepsRaw> steps;
  final DateTime windowStart;
  final DateTime windowEnd;

  StepsChartPainter({
    required this.steps,
    required this.windowStart,
    required this.windowEnd,
  });

  // Pre-allocated Paint objects for zero-allocation in paint()
  static final Paint _barPaint = Paint()
    ..color = Colors.blue.withOpacity(0.6)
    ..style = PaintingStyle.fill;

  static final Paint _axisPaint = Paint()
    ..color = Colors.black12
    ..strokeWidth = 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (steps.isEmpty) return;

    final double width = size.width;
    final double height = size.height;
    final double totalTimeMs = windowEnd
        .difference(windowStart)
        .inMilliseconds
        .toDouble();

    // Find max steps for Y scaling
    int maxSteps = 10;
    for (int i = 0; i < steps.length; i++) {
      if (steps[i].count > maxSteps) maxSteps = steps[i].count;
    }
    final double yScale = height / (maxSteps * 1.2);

    // Draw grid lines
    for (int i = 0; i <= 4; i++) {
      final y = height - (i * height / 4);
      canvas.drawLine(Offset(0, y), Offset(width, y), _axisPaint);
    }

    // Draw bars
    final double barWidth =
        (width / 60) * 0.8; // Approx width for 1 min buckets

    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      final msOffset = step.timestamp.difference(windowStart).inMilliseconds;

      if (msOffset < 0 || msOffset > totalTimeMs) continue;

      final x = (msOffset / totalTimeMs) * width;
      final barHeight = step.count * yScale;

      // Draw standard rect bar
      canvas.drawRect(
        Rect.fromLTWH(
          x - barWidth / 2,
          height - barHeight,
          barWidth,
          barHeight,
        ),
        _barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant StepsChartPainter oldDelegate) {
    // Avoid redraw if data hasn't changed.
    return oldDelegate.steps != steps ||
        oldDelegate.windowStart != windowStart ||
        oldDelegate.windowEnd != windowEnd;
  }
}
