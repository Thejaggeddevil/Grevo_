import 'dart:async';
import '../models/energy_data.dart';

enum SocketConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

abstract class SocketBase {
  Stream<EnergyData> get energyDataStream;
  Stream<SocketConnectionState> get connectionStateStream;
  Stream<String> get errorStream;

  SocketConnectionState get connectionState;
  bool get isConnected;

  void connect();
  void disconnect();
  void reconnect();

  void subscribeToCampus(String campusId);
  void unsubscribeFromCampus(String campusId);
  void subscribeToAllUpdates();
  void unsubscribeFromAllUpdates();
  void requestLatestData(String campusId);
  void ping();

  void dispose();
}
