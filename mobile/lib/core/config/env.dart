/// Konfigurasi Environment Aplikasi
/// Nilai dimuat melalui `--dart-define-from-file=env/dev.json`
class Env {
  Env._();

  /// Base URL Backend API (backend yang sama dengan aplikasi web)
  /// Default fallback ke emulator Android: http://10.0.2.2:5000/api/v1
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api/v1',
  );

  /// Timeout jaringan dalam milidetik
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 30000;

  /// Origin server API, mis. `http://10.0.2.2:5000`
  static Uri get apiOrigin {
    final base = Uri.parse(apiBaseUrl);
    return Uri(scheme: base.scheme, host: base.host, port: base.port);
  }

  /// Menyesuaikan URL berkas dari server (poster, bukti presensi) agar bisa
  /// dibuka dari perangkat.
  ///
  /// Backend membentuk URL berkas dari `PUBLIC_URL` (umumnya
  /// `http://localhost:5000`). Dari emulator/HP, `localhost` menunjuk ke
  /// perangkat itu sendiri, sehingga host lokal diganti dengan host API.
  static String? resolveMediaUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final value = url.trim();
    if (value.startsWith('data:')) return value;
    if (value.startsWith('/')) return apiOrigin.resolve(value).toString();
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) return value;
    const localHosts = {'localhost', '127.0.0.1', '0.0.0.0'};
    if (localHosts.contains(uri.host)) {
      final origin = apiOrigin;
      return uri
          .replace(scheme: origin.scheme, host: origin.host, port: origin.port)
          .toString();
    }
    return value;
  }
}
