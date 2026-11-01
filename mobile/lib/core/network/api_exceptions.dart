/// Kelas exception khusus untuk kesalahan jaringan dan API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final List<String> errors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errors = const [],
  });

  @override
  String toString() {
    if (errors.isNotEmpty) {
      return '$message (${errors.join(", ")})';
    }
    return message;
  }
}

class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'Gagal terhubung ke server. Periksa koneksi internet Anda atau pastikan server backend aktif.',
    super.statusCode,
    super.errors,
  });
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Sesi telah berakhir atau tidak valid. Silakan login kembali.',
    super.statusCode = 401,
    super.errors,
  });
}

class ForbiddenRoleException extends ApiException {
  const ForbiddenRoleException({
    super.message = 'Akun ini bukan akun peserta. Silakan gunakan aplikasi web.',
    super.statusCode = 403,
    super.errors,
  });
}

