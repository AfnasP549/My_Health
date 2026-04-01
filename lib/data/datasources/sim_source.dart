import 'dart:async';
import 'dart:math';
import '../../domain/entities/health_data.dart';

class SimSource {
  final _random = Random();
  final _stepsController = StreamController<List<StepsRaw>>.broadcast();
  final _hrController = StreamController<List<HrRaw>>.broadcast();
  Timer? _timer;
  bool _active = false;

  Stream<List<StepsRaw>> get stepsStream => _stepsController.stream;
  Stream<List<HrRaw>> get heartRateStream => _hrController.stream;

  void start(Duration interval) {
    if (_active) return;
    _active = true;
    _timer = Timer.periodic(interval, (timer) {
      // Periodic Step update (add 5-20 steps)
      final steps = [
        StepsRaw(
          timestamp: DateTime.now(),
          count: 5 + _random.nextInt(15),
        )
      ];
      _stepsController.add(steps);

      // Periodic HR update (60-100 bpm)
      final hr = [
        HrRaw(
          timestamp: DateTime.now(),
          bpm: 60 + _random.nextInt(40),
        )
      ];
      _hrController.add(hr);
    });
  }

  void stop() {
    _timer?.cancel();
    _active = false;
  }

  void dispose() {
    stop();
    _stepsController.close();
    _hrController.close();
  }
}
