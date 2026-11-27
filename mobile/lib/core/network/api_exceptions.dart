/// Kelas exception khusus untuk kesalahan jaringan dan API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final List<String> errors;

  /// Kode keadaan dari backend (mis. presensi: `invalid-code`,
  /// `outside-radius`, `closed`). Dikirim server pada `errors[0].state`.
  final String? state;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errors = const [],
    this.state,
  });

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException({
    super.message =
        'Gagal terhubung ke server. Periksa koneksi internet Anda atau pastikan server backend aktif.',
    super.statusCode,
    super.errors,
  });
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message =
        'Sesi telah berakhir atau tidak valid. Silakan login kembali.',
    super.statusCode = 401,
    super.errors,
  });
}

class ForbiddenRoleException extends ApiException {
  const ForbiddenRoleException({
    super.message =
        'Akun ini bukan akun peserta. Silakan gunakan aplikasi web.',
    super.statusCode = 403,
    super.errors,
  });
}
