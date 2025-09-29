import '../config/app_config.dart';
import 'api_base.dart';
import 'socket_base.dart';
import 'api_service.dart';
import 'socket_service.dart';
import 'mock_api_service.dart';
import 'mock_socket_service.dart';

// Unified service accessors used across the app
// They select mock or real implementations based on AppConfig.useMockBackend
final ApiBase api = AppConfig.useMockBackend ? mockApiService : apiService;
final SocketBase socket = AppConfig.useMockBackend ? mockSocketService : socketService;
