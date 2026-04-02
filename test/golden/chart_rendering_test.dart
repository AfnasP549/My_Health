import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_health/domain/entities/health_data.dart';
import 'package:my_health/presentation/painters/steps_chart_painter.dart';
import 'package:my_health/presentation/painters/heart_rate_painter.dart';

void main() {
  testWidgets('Charts render without crashing', (WidgetTester tester) async {
    final now = DateTime(2026, 4, 1, 12, 0);
    
    // Testing both painters in one test to minimize overhead
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(
                width: 300,
                height: 200,
                child: CustomPaint(
                  painter: StepsChartPainter(
                    steps: [StepsRaw(count: 100, timestamp: now)],
                    windowStart: now.subtract(const Duration(hours: 1)),
                    windowEnd: now,
                  ),
                ),
              ),
              SizedBox(
                width: 300,
                height: 200,
                child: CustomPaint(
                  painter: HeartRatePainter(
                    heartRates: [HrRaw(bpm: 70, timestamp: now)],
                    windowStart: now.subtract(const Duration(hours: 1)),
                    windowEnd: now,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(CustomPaint), findsNWidgets(2));
  });
}
