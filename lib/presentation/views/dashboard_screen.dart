import 'package:flutter/material.dart';
import '../widgets/permissions_banner.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Dashboard'),
      ),
      body: Column(
        children: const [
          PermissionsBanner(),
          Expanded(
            child: Center(
              child: Text('Live Dashboard Data Loading...'),
            ),
          ),
        ],
      ),
    );
  }
}
