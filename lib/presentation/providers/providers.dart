import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/repositories/health_repository.dart';
import '../../data/repositories/sim_health_repository.dart';
import '../../data/repositories/health_connect_repository.dart';

// Provider to manage which data source is currently active
// false = Real Data (Health Connect)
// true = Fake Data (Simulated Source)
final simModeProvider = StateProvider<bool>((ref) => true);

// Dynamically provide the correct repository based on simMode
final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  final isSimulated = ref.watch(simModeProvider);

  if (isSimulated) {
    return SimHealthRepository()..startListening(const Duration(seconds: 5));
  } else {
    return HealthConnectRepository()
      ..startListening(const Duration(seconds: 10));
  }
});
