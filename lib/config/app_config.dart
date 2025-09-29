// Global app configuration
class AppConfig {
  // When true, the app uses in-app mock services (no network needed)
  static const bool useMockBackend = bool.fromEnvironment('USE_MOCK', defaultValue: true);
}
