import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/views/permissions_screen.dart';
import 'presentation/providers/providers.dart';
import 'data/repositories/sim_health_repository.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        healthRepositoryProvider.overrideWithValue(SimHealthRepository()..startListening(const Duration(seconds: 5))),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PermissionsScreen(),
    );
  }
}
