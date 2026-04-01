import 'package:flutter/material.dart';
import '../../../domain/entities/health_data.dart';
import '../../painters/heart_rate_painter.dart';

class InteractiveHeartRateChart extends StatefulWidget {
  final List<HrRaw> heartRates;
  final DateTime windowStart;
  final DateTime windowEnd;

  const InteractiveHeartRateChart({
    super.key,
    required this.heartRates,
    required this.windowStart,
    required this.windowEnd,
  });

  @override
  State<InteractiveHeartRateChart> createState() => _InteractiveHeartRateChartState();
}

class _InteractiveHeartRateChartState extends State<InteractiveHeartRateChart> {
  Offset? _touchPosition;
  double _zoomLevel = 1.0;
  double _horizontalOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (details) {
        setState(() {
          _zoomLevel = (_zoomLevel * details.scale).clamp(1.0, 5.0);
          _horizontalOffset += details.focalPointDelta.dx;
        });
      },
      onLongPressStart: (details) => setState(() => _touchPosition = details.localPosition),
      onLongPressMoveUpdate: (details) => setState(() => _touchPosition = details.localPosition),
      onLongPressEnd: (_) => setState(() => _touchPosition = null),
      child: Stack(
        children: [
          Transform.translate(
            offset: Offset(_horizontalOffset, 0),
            child: Transform.scale(
              scaleX: _zoomLevel,
              alignment: Alignment.centerLeft,
              child: CustomPaint(
                size: Size.infinite,
                painter: HeartRatePainter(
                  heartRates: widget.heartRates,
                  windowStart: widget.windowStart,
                  windowEnd: widget.windowEnd,
                ),
              ),
            ),
          ),
          if (_touchPosition != null) _buildTooltip(),
        ],
      ),
    );
  }

  Widget _buildTooltip() {
    if (widget.heartRates.isEmpty) return const SizedBox.shrink();

    final size = MediaQuery.of(context).size;
    final chartWidth = size.width - 64;
    final totalMs = widget.windowEnd.difference(widget.windowStart).inMilliseconds;
    
    final xPercent = _touchPosition!.dx / chartWidth;
    final targetTime = widget.windowStart.add(Duration(milliseconds: (totalMs * xPercent).toInt()));
    
    HrRaw? nearest;
    int minDiff = 999999999;
    
    for (var h in widget.heartRates) {
      final diff = h.timestamp.difference(targetTime).inMilliseconds.abs();
      if (diff < minDiff) {
        minDiff = diff;
        nearest = h;
      }
    }

    if (nearest == null) return const SizedBox.shrink();

    return Positioned(
      left: _touchPosition!.dx,
      top: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '${nearest.bpm} BPM\n${nearest.timestamp.hour}:${nearest.timestamp.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ),
    );
  }
}
