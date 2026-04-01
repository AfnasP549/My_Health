import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/permissions_viewmodel.dart';

class PermissionsBanner extends ConsumerWidget {
  const PermissionsBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(permissionsProvider);

    // Only show banner if permission has been explicitly denied.
    if (permissionState == UIState.denied) {
      return Container(
        width: double.infinity,
        color: Colors.orange.shade100,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Access to your Health Connect data is disabled.',
                style: TextStyle(
                  color: Colors.black87, 
                  fontSize: 13, 
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => ref.read(permissionsProvider.notifier).requestPermissions(),
              child: const Text('Enable Now'),
            ),
          ],
        ),
      );
    }

    // Hide for initial, authorized, or requesting states.
    return const SizedBox.shrink();
  }
}
