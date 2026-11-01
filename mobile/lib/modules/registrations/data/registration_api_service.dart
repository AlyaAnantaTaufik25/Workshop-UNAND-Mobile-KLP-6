import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_response.dart';

/// Service API Pendaftaran Workshop Peserta [PLANNED]
class RegistrationApiService {
  final Dio _dio;

  RegistrationApiService(this._dio);

  /// Mendaftar ke workshop (POST /registrations)
  // TODO: Hubungkan ke backend saat endpoint siap
  Future<ApiResponse<dynamic>> registerToWorkshop(String idKegiatan) async {
    throw UnimplementedError('Endpoint POST ${ApiEndpoints.registrations} masih dalam rencana pengembangan backend.');
  }

  /// Mengambil daftar workshop yang didaftarkan oleh peserta (GET /registrations/my)
  // TODO: Hubungkan ke backend saat endpoint siap
  Future<ApiResponse<List<dynamic>>> getMyRegistrations() async {
    throw UnimplementedError('Endpoint GET ${ApiEndpoints.myRegistrations} masih dalam rencana pengembangan backend.');
  }

  /// Membatalkan pendaftaran (PATCH /registrations/:id/cancel)
  // TODO: Hubungkan ke backend saat endpoint siap
  Future<ApiResponse<dynamic>> cancelRegistration(String registrationId) async {
    throw UnimplementedError('Endpoint PATCH ${ApiEndpoints.cancelRegistration(registrationId)} masih dalam rencana pengembangan backend.');
  }
}

