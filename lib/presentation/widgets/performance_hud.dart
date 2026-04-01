import 'dart:async';
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
  double _buildTime = 0;
  DateTime _lastFrame = DateTime.now();
  final List<double> _buildTimes = [];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  void _onFrame(Duration timestamp) {
    if (!mounted) return;

    final now = DateTime.now();
    final frameTime = now.difference(_lastFrame).inMilliseconds;
    if (frameTime > 0) {
      _fps = 1000 / frameTime;
    }
    _lastFrame = now;

    // Use a small trick to estimate build time using SchedulerBinding
    final stopwatch = Stopwatch()..start();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _buildTime = stopwatch.elapsedMicroseconds / 1000;
      _buildTimes.add(_buildTime);
      if (_buildTimes.length > 60) _buildTimes.removeAt(0);
      if (mounted) setState(() {});
    });

    SchedulerBinding.instance.addPostFrameCallback(_onFrame);
  }

  double get _avgBuildTime => _buildTimes.isEmpty
      ? 0
      : _buildTimes.reduce((a, b) => a + b) / _buildTimes.length;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 40,
          right: 10,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                //  color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Text(
                  //   'FPS: ${_fps.toStringAsFixed(1)}',
                  //   style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                  // ),
                  // Text(
                  //   'Build: ${_buildTime.toStringAsFixed(2)}ms',
                  //   style: const TextStyle(color: Colors.white, fontSize: 10),
                  // ),
                  // Text(
                  //   'Avg: ${_avgBuildTime.toStringAsFixed(2)}ms',
                  //   style: const TextStyle(color: Colors.white, fontSize: 10),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
