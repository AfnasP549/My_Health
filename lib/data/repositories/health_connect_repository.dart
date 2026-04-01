import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import '../../domain/entities/health_data.dart';
import '../../domain/repositories/health_repository.dart';

class HealthConnectRepository implements HealthRepository {
  final Health _health = Health();
  bool _isSimulationMode = false;
  final _stepsController = StreamController<List<StepsRaw>>.broadcast();
  final _hrController = StreamController<List<HrRaw>>.broadcast();
  Timer? _pollTimer;

  static const types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
  ];

  @override
  Future<bool> checkPermissions() async {
    return await _health.hasPermissions(types) ?? false;
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      return await _health.requestAuthorization(types);
    } catch (e) {
      debugPrint('Health permission error: \$e');
      return false;
    }
  }

  @override
  Future<List<StepsRaw>> getSteps(DateTime start, DateTime end) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: [HealthDataType.STEPS],
      );
      return data
          .map((e) => StepsRaw(
                timestamp: e.dateFrom,
                count: int.tryParse(e.value.toString()) ?? 0,
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<HrRaw>> getHeartRate(DateTime start, DateTime end) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: [HealthDataType.HEART_RATE],
      );
      return data
          .map((e) => HrRaw(
                timestamp: e.dateFrom,
                bpm: double.tryParse(e.value.toString())?.toInt() ?? 0,
              ))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<StepsRaw>> get stepsStream => _stepsController.stream;

  @override
  Stream<List<HrRaw>> get heartRateStream => _hrController.stream;

  @override
  void startListening(Duration pollInterval) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(pollInterval, (timer) async {
      if (!_isSimulationMode) {
        final now = DateTime.now();
        final start = now.subtract(pollInterval);
        
        final steps = await getSteps(start, now);
        if (steps.isNotEmpty) _stepsController.add(steps);
        
        final hr = await getHeartRate(start, now);
        if (hr.isNotEmpty) _hrController.add(hr);
      }
    });
  }

  @override
  void stopListening() {
    _pollTimer?.cancel();
  }

  @override
  void setSimulationMode(bool enabled) {
    _isSimulationMode = enabled;
  }

  @override
  bool get isSimulationMode => _isSimulationMode;
}
