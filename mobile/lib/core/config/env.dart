/// Konfigurasi Environment Aplikasi
/// Nilai dimuat melalui `--dart-define-from-file=env/dev.json`
class Env {
  Env._();

  /// Base URL Backend API
  /// Default fallback ke emulator Android: http://10.0.2.2:5000/api/v1
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api/v1',
  );

  /// Timeout jaringan dalam milidetik
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
}

