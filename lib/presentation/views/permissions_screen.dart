import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/permissions_viewmodel.dart';
import 'dashboard_screen.dart';

class PermissionsScreen extends ConsumerWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(permissionsProvider);

    // If we've already asked (Authorized or Denied), show the dashboard.
    // Dashboard and its banner handle the internal "permission denied" state.
    if (permissionState == UIState.authorized ||
        permissionState == UIState.denied) {
      return const DashboardScreen();
    }

    if (permissionState == UIState.initial) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildRequestUI(context, ref),
    );
  }

  Widget _buildRequestUI(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, size: 64, color: Colors.blue),
          ),
          const SizedBox(height: 32),
          const Text(
            'Keep Track of Your Health',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'We need access to your activity and heart rate to give you a real-time dashboard. Your data remains on-device and completely offline.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                ref.read(permissionsProvider.notifier).requestPermissions();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Allow Access',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: TextButton(
              onPressed: () {
                ref.read(permissionsProvider.notifier).denyPermissions();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black45,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Not Now',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
