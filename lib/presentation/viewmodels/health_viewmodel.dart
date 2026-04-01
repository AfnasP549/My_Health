import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/entities/health_data.dart';
import '../providers/providers.dart';

class HealthDataState {
  final List<StepsRaw> steps;
  final List<HrRaw> heartRates;
  final int todayStepsCount;
  final HrRaw? lastHeartRate;

  HealthDataState({
    this.steps = const [],
    this.heartRates = const [],
    this.todayStepsCount = 0,
    this.lastHeartRate,
  });

  HealthDataState copyWith({
    List<StepsRaw>? steps,
    List<HrRaw>? heartRates,
    int? todayStepsCount,
    HrRaw? lastHeartRate,
  }) {
    return HealthDataState(
      steps: steps ?? this.steps,
      heartRates: heartRates ?? this.heartRates,
      todayStepsCount: todayStepsCount ?? this.todayStepsCount,
      lastHeartRate: lastHeartRate ?? this.lastHeartRate,
    );
  }
}

class HealthViewModel extends StateNotifier<HealthDataState> {
  HealthViewModel(this.ref) : super(HealthDataState()) {
    _init();
  }

  final Ref ref;
  StreamSubscription? _stepsSub;
  StreamSubscription? _hrSub;

  void _init() {
    final repo = ref.read(healthRepositoryProvider);

    // Initial fetch for today's total steps (mocked for now in sim)
    _fetchInitialData();

    // Listen to real-time streams (Polling or SimSource)
    _stepsSub = repo.stepsStream.listen((newSteps) {
      _processNewSteps(newSteps);
    });

    _hrSub = repo.heartRateStream.listen((newHr) {
      _processNewHr(newHr);
    });

    // Start the repository's internal listener/poller (using 10s as per task repo)
    repo.startListening(const Duration(seconds: 10));
  }

  Future<void> _fetchInitialData() async {
    final repo = ref.read(healthRepositoryProvider);
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final steps = await repo.getSteps(startOfDay, now);
    final hr = await repo.getHeartRate(
      now.subtract(const Duration(hours: 1)),
      now,
    );

    state = state.copyWith(
      steps: steps,
      heartRates: hr,
      todayStepsCount: steps.fold(0, (sum, item) => sum! + item.count),
      lastHeartRate: hr.isEmpty ? null : hr.last,
    );
  }

  void _processNewSteps(List<StepsRaw> newSteps) {
    if (newSteps.isEmpty) return;

    // Merge and deduplicate logic (using map by timestamp)
    final existingSteps = {
      for (var s in state.steps) s.timestamp.toIso8601String(): s,
    };
    for (var s in newSteps) {
      existingSteps[s.timestamp.toIso8601String()] = s;
    }

    final merged = existingSteps.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Keep last 60 minutes window as per requirement
    final hourAgo = DateTime.now().subtract(const Duration(minutes: 60));
    final windowed = merged.where((s) => s.timestamp.isAfter(hourAgo)).toList();

    state = state.copyWith(
      steps: windowed,
      todayStepsCount:
          state.todayStepsCount + newSteps.fold(0, (sum, s) => sum + s.count),
    );
  }

  void _processNewHr(List<HrRaw> newHr) {
    if (newHr.isEmpty) return;

    final existingHr = {
      for (var h in state.heartRates) h.timestamp.toIso8601String(): h,
    };
    for (var h in newHr) {
      existingHr[h.timestamp.toIso8601String()] = h;
    }

    final merged = existingHr.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Point decimation or resampling would happen here for large counts in later steps.
    // For now, simple window maintenance.
    final hourAgo = DateTime.now().subtract(const Duration(minutes: 60));
    final windowed = merged.where((h) => h.timestamp.isAfter(hourAgo)).toList();

    state = state.copyWith(
      heartRates: windowed,
      lastHeartRate: windowed.isEmpty ? null : windowed.last,
    );
  }

  @override
  void dispose() {
    _stepsSub?.cancel();
    _hrSub?.cancel();
    ref.read(healthRepositoryProvider).stopListening();
    super.dispose();
  }
}

final healthViewModelProvider =
    StateNotifierProvider<HealthViewModel, HealthDataState>((ref) {
      return HealthViewModel(ref);
    });
