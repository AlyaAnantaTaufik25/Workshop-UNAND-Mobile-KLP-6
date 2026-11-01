/// Daftar endpoint REST API (mengacu pada docs/api-contract.md)
class ApiEndpoints {
  ApiEndpoints._();

  // Sistem & Health Check [ACTIVE]
  static const String health = '/health';

  // Autentikasi [PLANNED]
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authMe = '/auth/me';
  static const String authLogout = '/auth/logout';

  // Kegiatan Workshop [PLANNED]
  static const String workshops = '/workshops';
  static String workshopDetail(String id) => '/workshops/$id';

  // Pendaftaran Workshop [PLANNED]
  static const String registrations = '/registrations';
  static const String myRegistrations = '/registrations/my';
  static String cancelRegistration(String id) => '/registrations/$id/cancel';

  // Presensi Kehadiran [PLANNED]
  static const String attendanceCheckIn = '/attendance/check-in';
  // PROPOSED: status kehadiran peserta per kegiatan
  static String myAttendance(String workshopId) => '/attendance/my/$workshopId';

  // Sertifikat [PLANNED]
  static const String myCertificates = '/certificates/my';
  static String verifyCertificate(String serialNumber) => '/certificates/verify/$serialNumber';
  // PROPOSED: unduh file sertifikat PDF
  static String downloadCertificate(String id) => '/certificates/$id/download';
  // PROPOSED: pengajuan perbaikan sertifikat
  static String certificateCorrection(String id) => '/certificates/$id/correction-requests';
}

