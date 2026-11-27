import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/data/participant_models.dart';
import '../../../core/network/api_call.dart';

/// Hasil login/registrasi: token JWT + profil pengguna
class AuthSession {
  const AuthSession({required this.token, required this.profile});
  final String token;
  final ParticipantProfile profile;
}

/// Service API Autentikasi (POST /auth/login, /auth/register, GET/PUT /auth/me)
class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  AuthSession _session(dynamic data) {
    final map = jsonMap(data);
    return AuthSession(
      token: jsonString(map['token']),
      profile: ParticipantProfile.fromJson(jsonMap(map['user'])),
    );
  }

  /// Registrasi akun peserta baru. Backend langsung mengembalikan token sesi.
  /// [jenis]: `Mahasiswa` atau `Umum`.
  Future<AuthSession> register({
    required String nama,
    required String email,
    required String password,
    String? telepon,
    String jenis = 'Umum',
    String? nim,
  }) =>
      apiCall(
        () => _dio.post(ApiEndpoints.authRegister, data: {
          'nama': nama,
          'email': email,
          'password': password,
          if (telepon != null && telepon.isNotEmpty) 'telepon': telepon,
          'jenis': jenis,
          if (nim != null && nim.isNotEmpty) 'nim': nim,
        }),
        _session,
      );

  /// Login dengan email & kata sandi
  Future<AuthSession> login({
    required String email,
    required String password,
  }) =>
      apiCall(
        () => _dio.post(ApiEndpoints.authLogin,
            data: {'email': email, 'password': password}),
        _session,
      );

  /// Profil pengguna yang sedang login
  Future<ParticipantProfile> getProfile() => apiCall(
        () => _dio.get(ApiEndpoints.authMe),
        (data) => ParticipantProfile.fromJson(jsonMap(data)),
      );

  /// Memperbarui profil (nama, telepon)
  Future<ParticipantProfile> updateProfile(
          {required String nama, required String telepon}) =>
      apiCall(
        () => _dio.put(ApiEndpoints.authMe,
            data: {'nama': nama, 'telepon': telepon}),
        (data) => ParticipantProfile.fromJson(jsonMap(data)),
      );

  /// Logout sesi (dicatat di audit log server)
  Future<void> logout() =>
      apiCall(() => _dio.post(ApiEndpoints.authLogout), (_) {});
}
