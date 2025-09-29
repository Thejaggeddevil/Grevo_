import '../models/campus.dart';
import '../models/energy_data.dart';

abstract class ApiBase {
  Future<List<Campus>> getCampuses();
  Future<Campus> getCampusById(String id);
  Future<List<EnergyData>> getEnergyData({
    String? campusId,
    DateTime? startTime,
    DateTime? endTime,
    int limit = 100,
  });
  Future<EnergyData?> getLatestEnergyData(String campusId);
  Future<List<Map<String, dynamic>>> getEnergyDataAggregated({
    required String campusId,
    required DateTime startTime,
    required DateTime endTime,
    String interval = 'hour',
  });
  Future<bool> isServerHealthy();
  Future<Map<String, dynamic>> getServerStatus();
  void dispose();
}
