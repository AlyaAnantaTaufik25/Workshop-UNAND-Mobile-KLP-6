import '../../../core/constants/app_roles.dart';
import '../../../core/data/participant_models.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/storage/session_storage.dart';
import 'auth_api_service.dart';

class AuthRepository {
  final AuthApiService _apiService;
  final SessionStorage _sessionStorage;

  AuthRepository(this._apiService, this._sessionStorage);

  /// Login dan validasi role khusus peserta.
  /// Sesi hanya disimpan bila role == peserta; selain itu
  /// [ForbiddenRoleException] dilempar dan tidak ada yang disimpan.
  Future<ParticipantProfile> login(String email, String password) async {
    final session = await _apiService.login(
        email: email.trim().toLowerCase(), password: password);
    return _accept(session);
  }

  /// Registrasi peserta baru lalu langsung masuk.
  Future<ParticipantProfile> register({
    required String nama,
    required String email,
    required String password,
    String? telepon,
    bool mahasiswa = false,
    String? nim,
  }) async {
    final session = await _apiService.register(
      nama: nama.trim(),
      email: email.trim().toLowerCase(),
      password: password,
      telepon: telepon?.trim(),
      jenis: mahasiswa ? 'Mahasiswa' : 'Umum',
      nim: nim?.trim(),
    );
    return _accept(session);
  }

  Future<ParticipantProfile> _accept(AuthSession session) async {
    if (session.profile.role.toLowerCase() != AppRoles.peserta) {
      await _sessionStorage.clearSession();
      throw const ForbiddenRoleException();
    }
    if (session.token.isEmpty) {
      throw const ApiException(message: 'Server tidak mengirim token sesi.');
    }
    await _sessionStorage.saveSession(
      token: session.token,
      userId: '${session.profile.id ?? ''}',
      role: session.profile.role,
      name: session.profile.name,
      email: session.profile.email,
    );
    return session.profile;
  }

  /// Memulihkan sesi tersimpan saat aplikasi dibuka.
  /// Mengembalikan null bila belum login atau token tidak berlaku lagi.
  Future<ParticipantProfile?> restoreSession() async {
    if (!await _sessionStorage.isLoggedIn() ||
        !await _sessionStorage.isPeserta()) {
      return null;
    }
    try {
      final profile = await _apiService.getProfile();
      if (profile.role.toLowerCase() != AppRoles.peserta) {
        await _sessionStorage.clearSession();
        return null;
      }
      return profile;
    } on UnauthorizedException {
      await _sessionStorage.clearSession();
      return null;
    }
  }

  Future<ParticipantProfile> updateProfile(
          {required String nama, required String telepon}) =>
      _apiService.updateProfile(nama: nama.trim(), telepon: telepon.trim());

  /// Logout: beri tahu server (best effort) lalu bersihkan secure storage
  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (_) {
      // Tetap keluar walaupun server tidak terjangkau
    } finally {
      await _sessionStorage.clearSession();
    }
  }
}
