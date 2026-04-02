// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class PerformanceHUD extends StatefulWidget {
  final Widget child;
  const PerformanceHUD({super.key, required this.child});

  @override
  State<PerformanceHUD> createState() => _PerformanceHUDState();
}

class _PerformanceHUDState extends State<PerformanceHUD> {
  double _fps = 0;
  double _lastBuildTime = 0;
  final List<double> _buildTimesWindow = [];
  Duration _lastFrameTimestamp = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Register the frame callback to measure timing
    SchedulerBinding.instance.addPostFrameCallback(_tick);
  }

  void _tick(Duration timestamp) {
    if (!mounted) return;

    final Duration delta = timestamp - _lastFrameTimestamp;
    if (delta.inMilliseconds > 0) {
      setState(() {
        _fps = 1000 / delta.inMilliseconds;

        // Use the Scheduler's internal measuring if available or estimate.
        // For local assertion, we measure the time between post-frame callbacks.
        _lastBuildTime = delta.inMicroseconds / 1000;

        _buildTimesWindow.add(_lastBuildTime);
        if (_buildTimesWindow.length > 60) {
          _buildTimesWindow.removeAt(0);
        }
      });
    }
    _lastFrameTimestamp = timestamp;

    // Schedule next frame check
    SchedulerBinding.instance.addPostFrameCallback(_tick);
  }

  double get _avgBuildTime => _buildTimesWindow.isEmpty
      ? 0
      : _buildTimesWindow.reduce((a, b) => a + b) / _buildTimesWindow.length;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 10,
          right: 15,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMetric(
                    'FPS',
                    _fps.toStringAsFixed(1),
                    _fps > 55 ? Colors.greenAccent : Colors.orangeAccent,
                  ),
                  const SizedBox(height: 4),
                  _buildMetric(
                    'Build Avg',
                    '${_avgBuildTime.toStringAsFixed(2)}ms',
                    _avgBuildTime < 8 ? Colors.blueAccent : Colors.redAccent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.normal,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}
