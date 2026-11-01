import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_response.dart';

/// Service API Sertifikat Peserta [PLANNED]
class CertificateApiService {
  final Dio _dio;

  CertificateApiService(this._dio);

  /// Mengambil daftar sertifikat milik peserta (GET /certificates/my)
  // TODO: Hubungkan ke backend saat endpoint siap
  Future<ApiResponse<List<dynamic>>> getMyCertificates() async {
    throw UnimplementedError('Endpoint GET ${ApiEndpoints.myCertificates} masih dalam rencana pengembangan backend.');
  }

  /// Verifikasi keabsahan nomor sertifikat publik (GET /certificates/verify/:serialNumber)
  // TODO: Hubungkan ke backend saat endpoint siap
  Future<ApiResponse<dynamic>> verifyCertificate(String serialNumber) async {
    throw UnimplementedError('Endpoint GET ${ApiEndpoints.verifyCertificate(serialNumber)} masih dalam rencana pengembangan backend.');
  }

  /// Mengunduh berkas PDF sertifikat (GET /certificates/:id/download)
  // TODO: PROPOSED endpoint
  Future<dynamic> downloadCertificatePdf(String id) async {
    throw UnimplementedError('Endpoint GET ${ApiEndpoints.downloadCertificate(id)} masih dalam rencana pengembangan backend.');
  }

  /// Mengajukan perbaikan sertifikat (POST /certificates/:id/correction-requests)
  // TODO: PROPOSED endpoint
  Future<ApiResponse<dynamic>> requestCorrection(String id, String keterangan) async {
    throw UnimplementedError('Endpoint POST ${ApiEndpoints.certificateCorrection(id)} masih dalam rencana pengembangan backend.');
  }
}

