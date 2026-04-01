class StepsRaw {
  final DateTime timestamp;
  final int count;

  StepsRaw({required this.timestamp, required this.count});

  @override
  String toString() => 'StepsRaw(timestamp: \$timestamp, count: \$count)';
}

class HrRaw {
  final DateTime timestamp;
  final int bpm;

  HrRaw({required this.timestamp, required this.bpm});

  @override
  String toString() => 'HrRaw(timestamp: \$timestamp, bpm: \$bpm)';
}
