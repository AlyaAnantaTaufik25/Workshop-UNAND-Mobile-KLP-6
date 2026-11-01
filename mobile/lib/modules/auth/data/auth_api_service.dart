import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_response.dart';

/// Service API Autentikasi
/// Seluruh endpoint masih bertatus [PLANNED] pada docs/api-contract.md
class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  /// Registrasi akun peserta baru (POST /auth/register)
  // TODO: Implementasikan pemanggilan endpoint saat backend auth siap
  Future<ApiResponse<dynamic>> register({
    required String nama,
    required String email,
    required String password,
    String? noTelepon,
  }) async {
    // Placeholder rencana pengembangan
    throw UnimplementedError('Endpoint POST ${ApiEndpoints.authRegister} masih dalam rencana pengembangan backend.');
  }

  /// Login akun peserta (POST /auth/login)
  // TODO: Implementasikan pemanggilan endpoint dan parsing JWT saat backend auth siap
  Future<ApiResponse<dynamic>> login({
    required String email,
    required String password,
  }) async {
    // Placeholder rencana pengembangan
    throw UnimplementedError('Endpoint POST ${ApiEndpoints.authLogin} masih dalam rencana pengembangan backend.');
  }

  /// Mengambil profil user yang sedang login (GET /auth/me)
  // TODO: Implementasikan GET auth/me
  Future<ApiResponse<dynamic>> getProfile() async {
    throw UnimplementedError('Endpoint GET ${ApiEndpoints.authMe} masih dalam rencana pengembangan backend.');
  }

  /// Logout sesi (POST /auth/logout)
  // TODO: Implementasikan POST auth/logout
  Future<ApiResponse<dynamic>> logout() async {
    throw UnimplementedError('Endpoint POST ${ApiEndpoints.authLogout} masih dalam rencana pengembangan backend.');
  }
}

