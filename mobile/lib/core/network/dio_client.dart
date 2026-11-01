import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/env.dart';
import '../storage/session_storage.dart';
import 'auth_interceptor.dart';

/// Provider klien Dio terpusat
class DioClient {
  final Dio dio;
  final SessionStorage sessionStorage;

  DioClient({
    required this.sessionStorage,
    Dio? customDio,
    void Function()? onSessionExpired,
  }) : dio = customDio ?? Dio() {
    dio.options = BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(milliseconds: Env.connectTimeout),
      receiveTimeout: const Duration(milliseconds: Env.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Pasang AuthInterceptor
    dio.interceptors.add(
      AuthInterceptor(
        sessionStorage: sessionStorage,
        onSessionExpired: onSessionExpired,
      ),
    );

    // Logging interceptor HANYA aktif saat mode debug
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint('[DIO] $obj'),
        ),
      );
    }
  }
}

