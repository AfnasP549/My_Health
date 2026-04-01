import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/permissions_viewmodel.dart';

class PermissionsBanner extends ConsumerWidget {
  const PermissionsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(permissionsProvider);

    return permissionState.when(
      data: (isGranted) {
        if (isGranted) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          color: Colors.orange.shade100,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Health permissions are not fully granted. Some data may be missing.',
                  style: TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ),
              TextButton(
                onPressed: () => ref.read(permissionsProvider.notifier).requestPermissions(),
                child: const Text('Grant Now'),
              ),
            ],
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => Container(
        color: Colors.red.shade100,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: const Text('Failed to check permissions.'),
      ),
    );
  }
}
