import 'dart:async';
import '../../domain/entities/health_data.dart';
import '../../domain/repositories/health_repository.dart';
import '../datasources/sim_source.dart';

class SimHealthRepository implements HealthRepository {
  SimHealthRepository() : _simSource = SimSource();

  final SimSource _simSource;
  bool _isSimulationMode = true;

  @override
  Future<bool> checkPermissions() async => true;

  @override
  Future<bool> requestPermissions() async => true;

  @override
  Future<List<StepsRaw>> getSteps(DateTime start, DateTime end) async {
    return [StepsRaw(timestamp: DateTime.now(), count: 100)];
  }

  @override
  Future<List<HrRaw>> getHeartRate(DateTime start, DateTime end) async {
    return [HrRaw(timestamp: DateTime.now(), bpm: 72)];
  }

  @override
  Stream<List<StepsRaw>> get stepsStream => _simSource.stepsStream;

  @override
  Stream<List<HrRaw>> get heartRateStream => _simSource.heartRateStream;

  @override
  void startListening(Duration pollInterval) {
    if (_isSimulationMode) {
      _simSource.start(pollInterval);
    }
  }

  @override
  void stopListening() {
    _simSource.stop();
  }

  @override
  void setSimulationMode(bool enabled) {
    _isSimulationMode = enabled;
    if (enabled) {
      _simSource.start(const Duration(seconds: 5));
    } else {
      _simSource.stop();
    }
  }

  @override
  bool get isSimulationMode => _isSimulationMode;
}
