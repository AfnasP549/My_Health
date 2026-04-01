import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/health_viewmodel.dart';
import '../viewmodels/permissions_viewmodel.dart';
import '../widgets/permissions_banner.dart';
import '../widgets/performance_hud.dart';
import '../widgets/summary_card.dart';
import '../widgets/charts/interactive_steps_chart.dart';
import '../widgets/charts/interactive_heart_rate_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _getTimeAgo(DateTime? time) {
    if (time == null) return "Never";
    // Using absolute diff to handle minor timestamp drift/future timestamps from sensors
    final diff = DateTime.now().difference(time).abs();
    
    if (diff.inSeconds < 1) return "Just now";
    if (diff.inSeconds < 60) return "${diff.inSeconds}s ago";
    return "${diff.inMinutes}m ago";
  }

  Widget _buildChartContainer(String label, Color bgColor, Widget chart) {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.fromLTRB(12, 40, 12, 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -28,
            left: 0,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black45,
              ),
            ),
          ),
          ClipRect(child: chart),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(healthViewModelProvider);
    final permissionState = ref.watch(permissionsProvider);
    final isAuthorized = permissionState == UIState.authorized;

    final now = DateTime.now();
    final hourAgo = now.subtract(const Duration(minutes: 60));

    return PerformanceHUD(
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text(
            'Health Realtime',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Column(
          children: [
            const PermissionsBanner(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: SummaryCard(
                              title: 'Today\'s Steps',
                              value: isAuthorized ? healthState.todayStepsCount.toString() : '--',
                              icon: Icons.directions_walk,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SummaryCard(
                              title: 'Heart Rate',
                              value: isAuthorized && healthState.lastHeartRate != null 
                                  ? '${healthState.lastHeartRate!.bpm}' 
                                  : '--',
                              subtitle: isAuthorized ? _getTimeAgo(healthState.lastHeartRate?.timestamp) : 'No permission',
                              icon: Icons.favorite,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildChartContainer(
                      'Steps History (Last 60m)', 
                      Colors.blue.shade50,
                      isAuthorized 
                        ? InteractiveStepsChart(
                            steps: healthState.steps,
                            windowStart: hourAgo,
                            windowEnd: now,
                          )
                        : const Center(child: Text("Permissions disabled", style: TextStyle(color: Colors.black26))),
                    ),
                    const SizedBox(height: 16),
                    _buildChartContainer(
                      'Heart Rate Rolling', 
                      Colors.red.shade50,
                      isAuthorized
                        ? InteractiveHeartRateChart(
                            heartRates: healthState.heartRates,
                            windowStart: hourAgo,
                            windowEnd: now,
                          )
                        : const Center(child: Text("Permissions disabled", style: TextStyle(color: Colors.black26))),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
