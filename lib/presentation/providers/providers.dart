import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/repositories/health_repository.dart';

// We will override this provider once the actual implementation (Sim vs Real) is built.
final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  throw UnimplementedError('healthRepositoryProvider must be overridden');
});

// Provides the current permission state
final permissionStateProvider = StateProvider<bool>((ref) => false);
