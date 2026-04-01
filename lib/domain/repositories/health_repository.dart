import '../entities/health_data.dart';

abstract class HealthRepository {
  /// Checks if health permissions are granted
  Future<bool> checkPermissions();
  
  /// Requests health permissions
  Future<bool> requestPermissions();
  
  /// Get steps data between two times
  Future<List<StepsRaw>> getSteps(DateTime start, DateTime end);
  
  /// Get heart rate data between two times
  Future<List<HrRaw>> getHeartRate(DateTime start, DateTime end);
  
  /// Listen to changes (Fallback B using polling wrapper, or SimSource)
  Stream<List<StepsRaw>> get stepsStream;
  Stream<List<HrRaw>> get heartRateStream;

  /// Starts the data gathering (polling or sim generation)
  void startListening(Duration pollInterval);
  void stopListening();

  void setSimulationMode(bool enabled);
  bool get isSimulationMode;
}
