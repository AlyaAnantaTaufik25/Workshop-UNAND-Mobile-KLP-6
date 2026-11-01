import '../../../core/constants/app_roles.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/storage/session_storage.dart';
import 'auth_api_service.dart';

class AuthRepository {
  final AuthApiService _apiService;
  final SessionStorage _sessionStorage;

  AuthRepository(this._apiService, this._sessionStorage);

  /// Login dan validasi role khusus peserta
  Future<void> login(String email, String password) async {
    // TODO: Panggil _apiService.login(email: email, password: password)
    // Simpan token hanya jika role == AppRoles.peserta
    // Jika bukan peserta, lemparkan ForbiddenRoleException
    throw const UnimplementedError('Modul login masih dalam rencana pengembangan.');
  }

  /// Registrasi peserta baru
  Future<void> register(String nama, String email, String password, String? noTelepon) async {
    // TODO: Implementasi saat backend siap
    throw const UnimplementedError('Modul registrasi masih dalam rencana pengembangan.');
  }

  /// Logout dan bersihkan secure storage
  Future<void> logout() async {
    try {
      // await _apiService.logout();
    } finally {
      await _sessionStorage.clearSession();
    }
  }

  /// Cek apakah peserta aktif login
  Future<bool> checkAuth() async {
    final isLoggedIn = await _sessionStorage.isLoggedIn();
    if (!isLoggedIn) return false;
    return await _sessionStorage.isPeserta();
  }
}

