import 'dart:async';
import 'dart:math';

import '../models/energy_data.dart';
import 'mock_api_service.dart';
import 'socket_base.dart';

class MockSocketService implements SocketBase {
  final StreamController<EnergyData> _energyDataController = StreamController<EnergyData>.broadcast();
  final StreamController<SocketConnectionState> _connectionStateController = StreamController<SocketConnectionState>.broadcast();
  final StreamController<String> _errorController = StreamController<String>.broadcast();

  SocketConnectionState _connectionState = SocketConnectionState.disconnected;
  Timer? _timer;
  final Set<String> _subscribedCampusIds = {};
  final Random _rng = Random(123);

  // Streams
  @override
  Stream<EnergyData> get energyDataStream => _energyDataController.stream;
  @override
  Stream<SocketConnectionState> get connectionStateStream => _connectionStateController.stream;
  @override
  Stream<String> get errorStream => _errorController.stream;

  @override
  SocketConnectionState get connectionState => _connectionState;
  @override
  bool get isConnected => _connectionState == SocketConnectionState.connected;

  @override
  void connect() async {
    if (_connectionState == SocketConnectionState.connected || _connectionState == SocketConnectionState.connecting) return;
    _setState(SocketConnectionState.connecting);
    await Future.delayed(const Duration(milliseconds: 300));
    _setState(SocketConnectionState.connected);
    _startStreaming();
  }

  @override
  void disconnect() {
    _timer?.cancel();
    _timer = null;
    _setState(SocketConnectionState.disconnected);
  }

  @override
  void reconnect() {
    disconnect();
    Future.delayed(const Duration(milliseconds: 300), connect);
  }

  @override
  void subscribeToCampus(String campusId) {
    _subscribedCampusIds.add(campusId);
  }

  @override
  void unsubscribeFromCampus(String campusId) {
    _subscribedCampusIds.remove(campusId);
  }

  @override
  void subscribeToAllUpdates() async {
    final campuses = await mockApiService.getCampuses();
    _subscribedCampusIds.addAll(campuses.map((c) => c.id));
  }

  @override
  void unsubscribeFromAllUpdates() {
    _subscribedCampusIds.clear();
  }

  @override
  void requestLatestData(String campusId) async {
    try {
      final data = await mockApiService.getLatestEnergyData(campusId);
      if (data != null) {
        _energyDataController.add(data);
      }
    } catch (e) {
      _errorController.add('Mock request error: $e');
    }
  }

  @override
  void ping() {
    // No-op for mock
  }

  void _startStreaming() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (_subscribedCampusIds.isEmpty) {
        // Default to first campus when nothing is subscribed yet
        final campuses = await mockApiService.getCampuses();
        if (campuses.isEmpty) return;
        _subscribedCampusIds.add(campuses.first.id);
      }

      for (final campusId in _subscribedCampusIds) {
        final jitterMs = _rng.nextInt(250);
        Future.delayed(Duration(milliseconds: jitterMs), () async {
          final data = await mockApiService.getLatestEnergyData(campusId);
          if (data != null) {
            _energyDataController.add(data);
          }
        });
      }
    });
  }

  void _setState(SocketConnectionState state) {
    if (_connectionState != state) {
      _connectionState = state;
      _connectionStateController.add(state);
    }
  }

  @override
  void dispose() {
    disconnect();
    _energyDataController.close();
    _connectionStateController.close();
    _errorController.close();
  }
}

final mockSocketService = MockSocketService();
