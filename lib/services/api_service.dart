import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/campus.dart';
import '../models/energy_data.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, [this.statusCode]);
  
  @override
  String toString() => 'ApiException: $message';
}

class ApiService {
  static const String _baseUrl = 'http://localhost:8000';
  static const Duration _timeout = Duration(seconds: 30);
  
  final http.Client _client = http.Client();
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Campus endpoints
  Future<List<Campus>> getCampuses() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/api/campuses'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Campus.fromJson(json)).toList();
      } else {
        throw ApiException(
          'Failed to fetch campuses: ${response.reasonPhrase}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<Campus> getCampusById(String id) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/api/campuses/$id'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return Campus.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        throw ApiException('Campus not found', 404);
      } else {
        throw ApiException(
          'Failed to fetch campus: ${response.reasonPhrase}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  // Energy data endpoints
  Future<List<EnergyData>> getEnergyData({
    String? campusId,
    DateTime? startTime,
    DateTime? endTime,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };

      if (campusId != null) {
        queryParams['campusId'] = campusId;
      }
      
      if (startTime != null) {
        queryParams['startTime'] = startTime.toIso8601String();
      }
      
      if (endTime != null) {
        queryParams['endTime'] = endTime.toIso8601String();
      }

      final uri = Uri.parse('$_baseUrl/api/energy-data').replace(
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      final response = await _client
          .get(uri, headers: _headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => EnergyData.fromJson(json)).toList();
      } else {
        throw ApiException(
          'Failed to fetch energy data: ${response.reasonPhrase}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  Future<EnergyData?> getLatestEnergyData(String campusId) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/api/energy-data/latest/$campusId'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return EnergyData.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null; // No data available
      } else {
        throw ApiException(
          'Failed to fetch latest energy data: ${response.reasonPhrase}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  // Historical data with aggregation
  Future<List<Map<String, dynamic>>> getEnergyDataAggregated({
    required String campusId,
    required DateTime startTime,
    required DateTime endTime,
    String interval = 'hour', // hour, day, week, month
  }) async {
    try {
      final queryParams = {
        'campusId': campusId,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'interval': interval,
      };

      final uri = Uri.parse('$_baseUrl/api/energy-data/aggregated').replace(
        queryParameters: queryParams,
      );

      final response = await _client
          .get(uri, headers: _headers)
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        throw ApiException(
          'Failed to fetch aggregated energy data: ${response.reasonPhrase}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  // Health check
  Future<bool> isServerHealthy() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/api/health'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get server status
  Future<Map<String, dynamic>> getServerStatus() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/api/status'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          'Failed to fetch server status: ${response.reasonPhrase}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  void dispose() {
    _client.close();
  }
}

// Singleton instance
final apiService = ApiService();