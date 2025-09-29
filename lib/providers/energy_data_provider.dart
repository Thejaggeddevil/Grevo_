import 'dart:async';
import 'package:flutter/material.dart';
import '../models/campus.dart';
import '../models/energy_data.dart';
import '../services/services.dart';
import '../services/socket_base.dart';

class EnergyDataProvider with ChangeNotifier {
  // State variables
  List<Campus> _campuses = [];
  Campus? _selectedCampus;
  EnergyData? _currentEnergyData;
  List<EnergyData> _historicalData = [];
  bool _isLoading = false;
  String? _error;
  bool _isConnected = false;

  // Stream subscriptions
  StreamSubscription<EnergyData>? _energyDataSubscription;
  StreamSubscription<SocketConnectionState>? _connectionSubscription;
  StreamSubscription<String>? _errorSubscription;

  // Getters
  List<Campus> get campuses => _campuses;
  Campus? get selectedCampus => _selectedCampus;
  EnergyData? get currentEnergyData => _currentEnergyData;
  List<EnergyData> get historicalData => _historicalData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _isConnected;
  bool get hasData => _currentEnergyData != null;

  EnergyDataProvider() {
    _initializeProvider();
  }

  void _initializeProvider() {
    _setupSocketListeners();
    _loadCampuses();
    socket.connect();
  }

  void _setupSocketListeners() {
    // Listen for real-time energy data updates
    _energyDataSubscription = socket.energyDataStream.listen(
      (energyData) {
        _currentEnergyData = energyData;
        
        // Add to historical data if it's for the selected campus
        if (_selectedCampus != null && energyData.campusId == _selectedCampus!.id) {
          _addToHistoricalData(energyData);
        }
        
        _clearError();
        notifyListeners();
      },
      onError: (error) {
        _setError('Real-time data error: $error');
      },
    );

    // Listen for connection state changes
    _connectionSubscription = socket.connectionStateStream.listen(
      (state) {
        _isConnected = state == SocketConnectionState.connected;
        
        // Subscribe to campus data when connected
        if (_isConnected && _selectedCampus != null) {
          socket.subscribeToCampus(_selectedCampus!.id);
        }
        
        notifyListeners();
      },
    );

    // Listen for socket errors
    _errorSubscription = socket.errorStream.listen(
      (errorMessage) {
        _setError(errorMessage);
      },
    );
  }

  void _addToHistoricalData(EnergyData data) {
    _historicalData.add(data);
    
    // Keep only last 100 data points to prevent memory issues
    if (_historicalData.length > 100) {
      _historicalData.removeAt(0);
    }
  }

  // Load all campuses
  Future<void> _loadCampuses() async {
    _setLoading(true);
    
    try {
      _campuses = await api.getCampuses();
      
      // Auto-select first campus if available
      if (_campuses.isNotEmpty && _selectedCampus == null) {
        await selectCampus(_campuses.first.id);
      }
      
      _clearError();
    } catch (e) {
      _setError('Failed to load campuses: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Refresh campuses list
  Future<void> refreshCampuses() async {
    await _loadCampuses();
  }

  // Select a campus
  Future<void> selectCampus(String campusId) async {
    try {
      // Unsubscribe from previous campus
      if (_selectedCampus != null) {
        socket.unsubscribeFromCampus(_selectedCampus!.id);
      }

      // Find and set new campus
      _selectedCampus = _campuses.firstWhere(
        (campus) => campus.id == campusId,
        orElse: () => throw Exception('Campus not found'),
      );

      // Clear previous data
      _currentEnergyData = null;
      _historicalData.clear();

      // Subscribe to new campus data
      if (_isConnected) {
        socket.subscribeToCampus(campusId);
        socket.requestLatestData(campusId);
      }

      // Load historical data
      await _loadHistoricalData(campusId);
      
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to select campus: $e');
    }
  }

  // Load historical energy data
  Future<void> _loadHistoricalData(String campusId) async {
    try {
      final endTime = DateTime.now();
      final startTime = endTime.subtract(const Duration(hours: 24));
      
      final historicalData = await api.getEnergyData(
        campusId: campusId,
        startTime: startTime,
        endTime: endTime,
        limit: 100,
      );
      
      _historicalData = historicalData;
      
      // Set current data to latest historical data if available
      if (historicalData.isNotEmpty && _currentEnergyData == null) {
        _currentEnergyData = historicalData.last;
      }
      
    } catch (e) {
      print('Failed to load historical data: $e');
      // Don't set error for historical data failure as it's not critical
    }
  }

  // Load historical data for specific time range
  Future<void> loadHistoricalData({
    required DateTime startTime,
    required DateTime endTime,
    String? campusId,
  }) async {
    final targetCampusId = campusId ?? _selectedCampus?.id;
    if (targetCampusId == null) return;

    _setLoading(true);

    try {
      final data = await api.getEnergyData(
        campusId: targetCampusId,
        startTime: startTime,
        endTime: endTime,
        limit: 1000,
      );

      _historicalData = data;
      _clearError();
    } catch (e) {
      _setError('Failed to load historical data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get aggregated data for charts
  Future<List<Map<String, dynamic>>> getAggregatedData({
    required DateTime startTime,
    required DateTime endTime,
    String interval = 'hour',
  }) async {
    if (_selectedCampus == null) {
      throw Exception('No campus selected');
    }

    try {
      return await api.getEnergyDataAggregated(
        campusId: _selectedCampus!.id,
        startTime: startTime,
        endTime: endTime,
        interval: interval,
      );
    } catch (e) {
      _setError('Failed to load aggregated data: $e');
      rethrow;
    }
  }

  // Refresh current data
  Future<void> refreshCurrentData() async {
    if (_selectedCampus == null) return;

    try {
      final latestData = await api.getLatestEnergyData(_selectedCampus!.id);
      if (latestData != null) {
        _currentEnergyData = latestData;
        _addToHistoricalData(latestData);
        _clearError();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to refresh data: $e');
    }
  }

  // Check server connection
  Future<void> checkServerConnection() async {
    try {
      final isHealthy = await api.isServerHealthy();
      if (!isHealthy) {
        _setError('Server is not responding');
      } else {
        // Backend is healthy. Clear error and ensure data is loaded.
        _clearError();
        if (_campuses.isEmpty) {
          await _loadCampuses();
        }
        if (_selectedCampus == null && _campuses.isNotEmpty) {
          await selectCampus(_campuses.first.id);
        }
      }
    } catch (e) {
      _setError('Connection error: $e');
    }
  }

  // Reconnect socket
  void reconnectSocket() {
    socket.reconnect();
  }

  // Utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // Get energy efficiency percentage
  double getEnergyEfficiency() {
    if (_currentEnergyData == null) return 0.0;

    final totalGeneration = _currentEnergyData!.solar.generation + 
                           _currentEnergyData!.wind.generation;
    final totalLoad = _currentEnergyData!.load.total;

    if (totalLoad == 0) return 0.0;
    return (totalGeneration / totalLoad * 100).clamp(0.0, 100.0);
  }

  // Get renewable energy percentage
  double getRenewablePercentage() {
    if (_currentEnergyData == null) return 0.0;

    final renewableGeneration = _currentEnergyData!.solar.generation + 
                               _currentEnergyData!.wind.generation;
    final totalConsumption = _currentEnergyData!.load.total + 
                            _currentEnergyData!.grid.export;

    if (totalConsumption == 0) return 0.0;
    return (renewableGeneration / totalConsumption * 100).clamp(0.0, 100.0);
  }

  // Get current power balance (positive = surplus, negative = deficit)
  double getPowerBalance() {
    if (_currentEnergyData == null) return 0.0;

    final totalGeneration = _currentEnergyData!.solar.generation + 
                           _currentEnergyData!.wind.generation +
                           _currentEnergyData!.battery.power; // Battery discharge is positive
    final totalConsumption = _currentEnergyData!.load.total;

    return totalGeneration - totalConsumption;
  }

  @override
  void dispose() {
    _energyDataSubscription?.cancel();
    _connectionSubscription?.cancel();
    _errorSubscription?.cancel();
    super.dispose();
  }
}