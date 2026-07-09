/// Application environment and API configuration.
///
/// Values come from compile-time `--dart-define` flags so CI and local runs
/// stay secret-free. Defaults match `apps/mobile/.env.example`.
class AppConfig {
  const AppConfig({
    required this.appEnv,
    required this.apiBaseUrl,
    required this.defaultLocale,
    required this.enableDemoLogin,
  });

  final String appEnv;
  final String apiBaseUrl;
  final String defaultLocale;
  final bool enableDemoLogin;

  bool get isLocal => appEnv == 'local' || appEnv == 'development';
  bool get isProduction => appEnv == 'production';

  /// Default config for local Android emulator → host machine API.
  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      appEnv: String.fromEnvironment('APP_ENV', defaultValue: 'local'),
      apiBaseUrl: String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://10.0.2.2:3000/api/v1',
      ),
      defaultLocale: String.fromEnvironment(
        'DEFAULT_LOCALE',
        defaultValue: 'en',
      ),
      enableDemoLogin: bool.fromEnvironment(
        'ENABLE_DEMO_LOGIN',
        defaultValue: true,
      ),
    );
  }

  /// iOS simulator / desktop / web localhost override.
  factory AppConfig.localhost({
    String appEnv = 'local',
    String defaultLocale = 'en',
    bool enableDemoLogin = true,
  }) {
    return AppConfig(
      appEnv: appEnv,
      apiBaseUrl: 'http://localhost:3000/api/v1',
      defaultLocale: defaultLocale,
      enableDemoLogin: enableDemoLogin,
    );
  }
}
