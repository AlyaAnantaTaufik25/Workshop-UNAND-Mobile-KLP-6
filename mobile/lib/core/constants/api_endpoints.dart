/// Daftar endpoint REST API backend SIM Workshop UNAND.
///
/// Backend yang dipakai adalah backend yang SAMA dengan aplikasi web
/// (repositori WorkshopFTIPPSI/backend), sehingga data web dan mobile selalu
/// sinkron. Path relatif terhadap [Env.apiBaseUrl] (`.../api/v1`).
class ApiEndpoints {
  ApiEndpoints._();

  // Sistem & Health Check
  static const String health = '/health';

  // Autentikasi
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authMe = '/auth/me';
  static const String authLogout = '/auth/logout';

  // Kegiatan Workshop (dengan token peserta: menyertakan `myRegistration`)
  static const String workshops = '/workshops';
  static String workshopDetail(String idOrSlug) =>
      '/workshops/${Uri.encodeComponent(idOrSlug)}';

  // Pendaftaran Workshop
  static const String registrations = '/registrations';
  static const String myRegistrations = '/registrations/my';
  static String cancelRegistration(int registrationId) =>
      '/registrations/$registrationId/cancel';

  // Presensi Kehadiran
  /// Offline: kode QR panitia + lokasi GPS (geofence)
  static const String attendanceCheckIn = '/attendance/check-in';

  /// Online: unggah screenshot bukti (menunggu verifikasi panitia)
  static const String attendanceUpload = '/attendance/upload';

  // Sertifikat
  static const String myCertificates = '/certificates/my';
  static String verifyCertificate(String serialNumber) =>
      '/certificates/verify/${Uri.encodeComponent(serialNumber)}';
  static String downloadCertificate(String code) =>
      '/certificates/issued/${Uri.encodeComponent(code)}/pdf';
  static const String certificateCorrections = '/certificates/corrections';

  // Notifikasi
  static const String notifications = '/notifications';
  static const String notificationsRead = '/notifications/read';
}
