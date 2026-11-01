import 'package:dio/dio.dart';
import '../storage/session_storage.dart';

/// Interceptor untuk menyisipkan header Authorization Bearer token otomatis
/// serta menangani invalidasi sesi saat menerima status HTTP 401
class AuthInterceptor extends Interceptor {
  final SessionStorage _sessionStorage;
  final void Function()? onSessionExpired;

  AuthInterceptor({
    required SessionStorage sessionStorage,
    this.onSessionExpired,
  }) : _sessionStorage = sessionStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _sessionStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Hapus sesi jika 401 Unauthorized
      await _sessionStorage.clearSession();
      onSessionExpired?.call();
    }
    handler.next(err);
  }
}

