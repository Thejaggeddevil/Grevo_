import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/energy_data.dart';

import 'socket_base.dart';

class SocketService implements SocketBase {
  static const String _serverUrl = 'http://localhost:8000';
  
  io.Socket? _socket;
  SocketConnectionState _connectionState = SocketConnectionState.disconnected;
  
  // Stream controllers for real-time data
  final StreamController<EnergyData> _energyDataController = 
      StreamController<EnergyData>.broadcast();
  final StreamController<SocketConnectionState> _connectionStateController = 
      StreamController<SocketConnectionState>.broadcast();
  final StreamController<String> _errorController = 
      StreamController<String>.broadcast();

  // Getters for streams
  @override
  Stream<EnergyData> get energyDataStream => _energyDataController.stream;
  @override
  Stream<SocketConnectionState> get connectionStateStream => 
      _connectionStateController.stream;
  @override
  Stream<String> get errorStream => _errorController.stream;
  
  @override
  SocketConnectionState get connectionState => _connectionState;
  @override
  bool get isConnected => _connectionState == SocketConnectionState.connected;

  @override
  void connect() {
    if (_socket != null && _socket!.connected) {
      return; // Already connected
    }

    _updateConnectionState(SocketConnectionState.connecting);

    try {
      _socket = io.io(_serverUrl, io.OptionBuilder()
          .setTransports(['websocket','polling'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(10000)
          .setReconnectionAttempts(5)
          .setTimeout(20000)
          .build());

      _setupEventHandlers();
    } catch (e) {
      _updateConnectionState(SocketConnectionState.error);
      _errorController.add('Failed to initialize socket: ${e.toString()}');
    }
  }

  void _setupEventHandlers() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      debugPrint('Socket connected to $_serverUrl');
      _updateConnectionState(SocketConnectionState.connected);
    });

    _socket!.onDisconnect((_) {
      debugPrint('Socket disconnected from $_serverUrl');
      _updateConnectionState(SocketConnectionState.disconnected);
    });

    _socket!.onConnectError((error) {
      debugPrint('Socket connection error: $error');
      _updateConnectionState(SocketConnectionState.error);
      _errorController.add('Connection error: ${error.toString()}');
    });

    _socket!.onError((error) {
      debugPrint('Socket error: $error');
      _errorController.add('Socket error: ${error.toString()}');
    });

    // Energy data events
    _socket!.on('energy-data', (data) {
      try {
        final energyData = EnergyData.fromJson(data);
        _energyDataController.add(energyData);
      } catch (e) {
        debugPrint('Error parsing energy data: $e');
        _errorController.add('Error parsing energy data: ${e.toString()}');
      }
    });

    // Campus-specific energy data
    _socket!.on('campus-energy-data', (data) {
      try {
        final energyData = EnergyData.fromJson(data);
        _energyDataController.add(energyData);
      } catch (e) {
        debugPrint('Error parsing campus energy data: $e');
        _errorController.add('Error parsing campus energy data: ${e.toString()}');
      }
    });

    // System alerts
    _socket!.on('system-alert', (data) {
      try {
        final alertData = Map<String, dynamic>.from(data);
        final message = alertData['message'] ?? 'System alert received';
        _errorController.add('System Alert: $message');
      } catch (e) {
        debugPrint('Error parsing system alert: $e');
      }
    });

    // Server status updates
    _socket!.on('server-status', (data) {
      try {
        debugPrint('Server status update: $data');
      } catch (e) {
        debugPrint('Error parsing server status: $e');
      }
    });
  }

  void _updateConnectionState(SocketConnectionState newState) {
    if (_connectionState != newState) {
      _connectionState = newState;
      _connectionStateController.add(newState);
    }
  }

  // Subscribe to energy data for a specific campus
  @override
  void subscribeToCampus(String campusId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('join-campus', {'campusId': campusId});
      debugPrint('Subscribed to campus: $campusId');
    } else {
      _errorController.add('Cannot subscribe: Socket not connected');
    }
  }

  // Unsubscribe from energy data for a specific campus
  @override
  void unsubscribeFromCampus(String campusId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('leave-campus', {'campusId': campusId});
      debugPrint('Unsubscribed from campus: $campusId');
    }
  }

  // Subscribe to all energy data updates
  @override
  void subscribeToAllUpdates() {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('subscribe-all', {});
      debugPrint('Subscribed to all energy updates');
    } else {
      _errorController.add('Cannot subscribe: Socket not connected');
    }
  }

  // Unsubscribe from all energy data updates
  @override
  void unsubscribeFromAllUpdates() {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('unsubscribe-all', {});
      debugPrint('Unsubscribed from all energy updates');
    }
  }

  // Request latest data for a campus
  @override
  void requestLatestData(String campusId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('get-latest-data', {'campusId': campusId});
    } else {
      _errorController.add('Cannot request data: Socket not connected');
    }
  }

  // Send a ping to test connection
  @override
  void ping() {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('ping', {'timestamp': DateTime.now().toIso8601String()});
    }
  }

  @override
  void disconnect() {
    try {
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
      _updateConnectionState(SocketConnectionState.disconnected);
      debugPrint('Socket disconnected and disposed');
    } catch (e) {
      debugPrint('Error during disconnect: $e');
    }
  }

  @override
  void dispose() {
    disconnect();
    _energyDataController.close();
    _connectionStateController.close();
    _errorController.close();
  }

  // Retry connection
  @override
  void reconnect() {
    disconnect();
    Future.delayed(const Duration(seconds: 2), () {
      connect();
    });
  }
}

// Singleton instance
final socketService = SocketService();
