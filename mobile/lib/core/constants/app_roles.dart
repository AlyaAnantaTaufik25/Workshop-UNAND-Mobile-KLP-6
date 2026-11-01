/// Konstanta Peran (Role) Pengguna
///
/// CATATAN PENTING ARSITEKTUR:
/// Aplikasi mobile ini KHUSUS untuk aktor PESERTA (mahasiswa UNAND dan umum).
/// Aktor Humas, Sekretariat Rektor, Mitra, dan Rektor menggunakan aplikasi web.
class AppRoles {
  AppRoles._();

  /// Satu-satunya peran yang diizinkan mengakses aplikasi mobile ini
  static const String peserta = 'peserta';
}

