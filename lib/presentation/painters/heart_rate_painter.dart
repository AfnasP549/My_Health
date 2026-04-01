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

  static final Path _path = Path();

  @override
  void paint(Canvas canvas, Size size) {
    if (heartRates.isEmpty) return;

    final double width = size.width;
    final double height = size.height;
    final double totalTimeMs = windowEnd.difference(windowStart).inMilliseconds.toDouble();

    // Use standard BPM scaling (40bpm to 200bpm or auto-scale)
    int maxHr = 150;
    int minHr = 60;
    for (int i = 0; i < heartRates.length; i++) {
        if (heartRates[i].bpm > maxHr) maxHr = heartRates[i].bpm;
        if (heartRates[i].bpm < minHr) minHr = heartRates[i].bpm;
    }
    
    final double hrRange = (maxHr - minHr).toDouble().clamp(20.0, 500.0);
    final double yScale = height / hrRange;

    _path.reset();
    bool first = true;

    for (int i = 0; i < heartRates.length; i++) {
        final hr = heartRates[i];
        final msOffset = hr.timestamp.difference(windowStart).inMilliseconds;
        
        if (msOffset < 0) continue;

        final x = (msOffset / totalTimeMs) * width;
        final y = height - ((hr.bpm - minHr) * yScale);

        if (first) {
            _path.moveTo(x, y);
            first = false;
        } else {
            _path.lineTo(x, y);
        }
    }

    canvas.drawPath(_path, _linePaint);
    
    // Gradient / Area fill below path
    if (!first) {
        final currentPath = Path()..addPath(_path, Offset.zero); // Temporary for fill logic
        currentPath.lineTo(width, height);
        currentPath.lineTo(0, height);
        currentPath.close();
        canvas.drawPath(currentPath, _areaPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HeartRatePainter oldDelegate) {
    return oldDelegate.heartRates != heartRates ||
           oldDelegate.windowStart != windowStart ||
           oldDelegate.windowEnd != windowEnd;
  }
}
