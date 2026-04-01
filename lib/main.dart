import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/providers/providers.dart';
import 'data/repositories/sim_health_repository.dart';
import 'presentation/views/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Make status bar transparent and text dark globally
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  final repo = SimHealthRepository();
  runApp(
    ProviderScope(
      overrides: [
        healthRepositoryProvider.overrideWithValue(
          repo..startListening(const Duration(seconds: 5)),
        ),
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
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
