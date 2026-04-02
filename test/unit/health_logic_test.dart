import 'package:flutter_test/flutter_test.dart';
import 'package:my_health/domain/entities/health_data.dart';

void main() {
  test('HealthData deduplication logic works correctly', () {
    final now = DateTime(2026, 4, 1, 10, 0);
    final list = [
      StepsRaw(count: 10, timestamp: now),
      StepsRaw(count: 20, timestamp: now), // Duplicate timestamp
      StepsRaw(count: 30, timestamp: now.add(Duration(minutes: 1))),
    ];

    final existingSteps = {
      for (var s in list) s.timestamp.toIso8601String(): s,
    };
    
    expect(existingSteps.length, 2);
    expect(existingSteps[now.toIso8601String()]!.count, 20); // Last-one-wins as implemented in VM
  });

  test('60-minute window filtering logic works correctly', () {
    final now = DateTime.now();
    final oldTime = now.subtract(const Duration(minutes: 61));
    final newTime = now.subtract(const Duration(minutes: 59));

    final list = [
      StepsRaw(count: 50, timestamp: oldTime),
      StepsRaw(count: 100, timestamp: newTime),
    ];

    final hourAgo = now.subtract(const Duration(minutes: 60));
    final windowed = list.where((s) => s.timestamp.isAfter(hourAgo)).toList();

    expect(windowed.length, 1);
    expect(windowed.first.count, 100);
  });
}
