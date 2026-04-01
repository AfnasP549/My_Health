import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../providers/providers.dart';

class PermissionsNotifier extends StateNotifier<AsyncValue<bool>> {
  PermissionsNotifier(this.ref) : super(const AsyncValue.loading()) {
    checkPermissions();
  }

  final Ref ref;

  Future<void> checkPermissions() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(healthRepositoryProvider);
      final hasPermission = await repo.checkPermissions();
      state = AsyncValue.data(hasPermission);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> requestPermissions() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(healthRepositoryProvider);
      final granted = await repo.requestPermissions();
      state = AsyncValue.data(granted);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final permissionsProvider =
    StateNotifierProvider<PermissionsNotifier, AsyncValue<bool>>((ref) {
      return PermissionsNotifier(ref);
    });
