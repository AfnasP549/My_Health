import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../providers/providers.dart';

enum UIState { initial, requesting, authorized, denied }

class PermissionsNotifier extends StateNotifier<UIState> {
  PermissionsNotifier(this.ref) : super(UIState.initial) {
    checkPermissions();
  }

  final Ref ref;

  Future<void> checkPermissions() async {
    try {
      final repo = ref.read(healthRepositoryProvider);
      final hasPermission = await repo.checkPermissions();
      if (hasPermission) {
        state = UIState.authorized;
      } else {
        state = UIState.requesting;
      }
    } catch (e) {
      state = UIState.requesting;
    }
  }

  Future<void> requestPermissions() async {
    final repo = ref.read(healthRepositoryProvider);
    try {
      final granted = await repo.requestPermissions();
      if (granted) {
        state = UIState.authorized;
      } else {
        state = UIState.denied;
      }
    } catch (e) {
      state = UIState.denied;
    }
  }

  void debugSkipPermissions() {
    state = UIState.authorized;
  }

  void denyPermissions() {
    state = UIState.denied;
  }
}

final permissionsProvider = StateNotifierProvider<PermissionsNotifier, UIState>(
  (ref) {
    return PermissionsNotifier(ref);
  },
);
