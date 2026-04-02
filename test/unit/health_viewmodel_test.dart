import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_health/domain/entities/health_data.dart';
import 'package:my_health/domain/repositories/health_repository.dart';
import 'package:my_health/presentation/providers/providers.dart';
import 'package:my_health/presentation/viewmodels/health_viewmodel.dart';
import 'dart:async';

@GenerateMocks([HealthRepository])
import 'health_viewmodel_test.mocks.dart';

void main() {
  test('ViewModel deduplicates data with identical timestamps', () async {
    final mockRepo = MockHealthRepository();
    final stepsController = StreamController<List<StepsRaw>>.broadcast();
    final hrController = StreamController<List<HrRaw>>.broadcast();

    when(mockRepo.stepsStream).thenAnswer((_) => stepsController.stream);
    when(mockRepo.heartRateStream).thenAnswer((_) => hrController.stream);
    when(mockRepo.getSteps(any, any)).thenAnswer((_) async => []);
    when(mockRepo.getHeartRate(any, any)).thenAnswer((_) async => []);
    when(mockRepo.startListening(any)).thenReturn(null);
    when(mockRepo.stopListening()).thenReturn(null);

    final container = ProviderContainer(
      overrides: [healthRepositoryProvider.overrideWithValue(mockRepo)],
    );

    // Get the notifier to initialize it
    container.read(healthViewModelProvider.notifier);

    final time = DateTime(2026, 4, 1, 10, 0);
    final data1 = [StepsRaw(count: 100, timestamp: time)];
    final data2 = [StepsRaw(count: 100, timestamp: time)];

    stepsController.add(data1);
    await Future.delayed(Duration.zero);
    stepsController.add(data2);
    await Future.delayed(Duration.zero);

    final state = container.read(healthViewModelProvider);
    expect(state.steps.length, 1);

    container.dispose();
    stepsController.close();
    hrController.close();
  });
}
