import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_roles.dart';

/// Penyimpanan sesi aman menggunakan FlutterSecureStorage
class SessionStorage {
  final FlutterSecureStorage _storage;

  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyRole = 'user_role';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';

  SessionStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  /// Menyimpan token autentikasi JWT
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  /// Mengambil token JWT
  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  /// Menyimpan informasi sesi lengkap setelah login berhasil
  Future<void> saveSession({
    required String token,
    required String userId,
    required String role,
    required String name,
    required String email,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyUserId, value: userId);
    await _storage.write(key: _keyRole, value: role);
    await _storage.write(key: _keyUserName, value: name);
    await _storage.write(key: _keyUserEmail, value: email);
  }

  /// Mengambil peran pengguna saat ini
  Future<String?> getRole() async {
    return await _storage.read(key: _keyRole);
  }

  /// Memeriksa apakah pengguna memiliki peran peserta
  ///
  /// CATATAN INSIASI:
  /// Aplikasi mobile ini HANYA boleh diakses oleh aktor 'peserta'.
  /// // TODO: Integrasikan validasi peran ketat saat modul login diimplementasikan
  Future<bool> isPeserta() async {
    final role = await getRole();
    if (role == null) return false;
    return role.toLowerCase() == AppRoles.peserta;
  }

  /// Memeriksa apakah user sedang login
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Menghapus seluruh data sesi (logout / sesi kedaluwarsa)
  Future<void> clearSession() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyRole);
    await _storage.delete(key: _keyUserName);
    await _storage.delete(key: _keyUserEmail);
  }
}

