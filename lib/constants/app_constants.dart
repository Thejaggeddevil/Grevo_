/// App-wide constants
library app_constants;

// App Information
class AppInfo {
  static const String appName = 'Grevo';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Renewable Energy Management';
  static const String appDescription = 
      'Monitor and manage renewable energy sources in real-time.';
  static const String copyright = '© 2024 Grevo Team';
  static const String websiteUrl = 'https://grevo.energy';
  static const String supportEmail = 'support@grevo.energy';
}

// API Configuration
class ApiConfig {
  // Default API URL for development
  static const String baseUrl = 'http://localhost:8000';
  
  // Production API URL (used when in release mode)
  static const String productionUrl = 'https://api.grevo.energy';
  
  // API Endpoints
  static const String campusesEndpoint = '/api/campuses';
  static const String energyDataEndpoint = '/api/energy-data';
  static const String latestDataEndpoint = '/api/energy-data/latest';
  static const String aggregatedDataEndpoint = '/api/energy-data/aggregated';
  static const String healthEndpoint = '/api/health';
  static const String statusEndpoint = '/api/status';
  
  // API Timeouts
  static const int connectionTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 60;
  
  // Retry Configuration
  static const int maxRetryAttempts = 3;
  static const int retryDelayMilliseconds = 1000;
}

// Socket Configuration
class SocketConfig {
  // Socket server URL (usually same as API base URL)
  static const String serverUrl = ApiConfig.baseUrl;
  
  // Socket Events
  static const String connectEvent = 'connect';
  static const String disconnectEvent = 'disconnect';
  static const String errorEvent = 'error';
  static const String energyDataEvent = 'energy-data';
  static const String campusEnergyDataEvent = 'campus-energy-data';
  static const String systemAlertEvent = 'system-alert';
  static const String serverStatusEvent = 'server-status';
  
  // Socket Actions
  static const String joinCampusAction = 'join-campus';
  static const String leaveCampusAction = 'leave-campus';
  static const String subscribeAllAction = 'subscribe-all';
  static const String unsubscribeAllAction = 'unsubscribe-all';
  static const String getLatestDataAction = 'get-latest-data';
  static const String pingAction = 'ping';
  
  // Socket Options
  static const List<String> transports = ['websocket'];
  static const int reconnectionDelayMilliseconds = 2000;
  static const int reconnectionDelayMaxMilliseconds = 10000;
  static const int reconnectionAttempts = 5;
  static const int timeoutMilliseconds = 20000;
}

// Local Storage Keys
class StorageKeys {
  static const String themeMode = 'theme_mode';
  static const String lastSelectedCampus = 'last_selected_campus';
  static const String userPreferences = 'user_preferences';
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String deviceId = 'device_id';
}

// Theme Constants
class ThemeConstants {
  // Light Theme Colors
  static const int lightPrimaryColor = 0xFF2E7D32; // Green
  static const int lightSecondaryColor = 0xFF4CAF50; // Light Green
  static const int lightAccentColor = 0xFFFFB74D; // Orange
  
  // Dark Theme Colors
  static const int darkPrimaryColor = 0xFF4CAF50; // Light Green
  static const int darkSecondaryColor = 0xFF81C784; // Lighter Green
  static const int darkAccentColor = 0xFFFFCC02; // Yellow
  
  // Energy Source Colors
  static const int solarColor = 0xFFFFA000; // Amber
  static const int windColor = 0xFF1976D2; // Blue
  static const int batteryColor = 0xFF388E3C; // Green
  static const int gridColor = 0xFF757575; // Gray
  static const int loadColor = 0xFFE64A19; // Deep Orange
  
  // Status Colors
  static const int successColor = 0xFF4CAF50; // Green
  static const int warningColor = 0xFFFF9800; // Orange
  static const int errorColor = 0xFFF44336; // Red
  static const int infoColor = 0xFF2196F3; // Blue
}

// Energy Related Constants
class EnergyConstants {
  // Energy Units
  static const String powerUnit = 'W';
  static const String energyUnit = 'Wh';
  static const String voltageUnit = 'V';
  static const String currentUnit = 'A';
  static const String frequencyUnit = 'Hz';
  static const String temperatureUnit = '°C';
  static const String irradianceUnit = 'W/m²';
  static const String windSpeedUnit = 'm/s';
  
  // Threshold Values
  static const double lowBatteryThreshold = 20.0; // %
  static const double criticalBatteryThreshold = 10.0; // %
  static const double highLoadThreshold = 90.0; // %
  static const double highTemperatureThreshold = 45.0; // °C
  static const double lowGridFrequencyThreshold = 49.5; // Hz
  static const double highGridFrequencyThreshold = 50.5; // Hz
  
  // Default Chart Data Points
  static const int defaultHistoricalDataPoints = 100;
  static const int maxHistoricalDataPoints = 1000;
  
  // Time Ranges
  static const Map<String, int> timeRangeHours = {
    '1H': 1,
    '6H': 6,
    '24H': 24,
    '7D': 24 * 7,
    '30D': 24 * 30,
  };
}

// App Routes
class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String campusDetails = '/campus/:id';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String analytics = '/analytics';
  static const String alerts = '/alerts';
  static const String profile = '/profile';
}

// Error Messages
class ErrorMessages {
  static const String networkError = 
      'Unable to connect to the server. Please check your internet connection.';
  static const String serverError = 
      'The server encountered an error. Please try again later.';
  static const String dataLoadError = 
      'Failed to load data. Please try again.';
  static const String authError = 
      'Authentication failed. Please log in again.';
  static const String socketConnectionError = 
      'Real-time connection failed. Retrying...';
  static const String noCampusesError = 
      'No campuses found. Please configure a campus in the system.';
  static const String noDataAvailable = 
      'No energy data available for the selected campus.';
}

// Validation Rules
class ValidationRules {
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 64;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 32;
  static const String emailRegex = 
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String passwordRegex = 
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
}

// Device Breakpoints
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1200;
  static const double desktop = 1920;
}
