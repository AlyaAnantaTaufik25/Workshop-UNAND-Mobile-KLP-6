import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_response.dart';

/// Service API Presensi Kehadiran [PLANNED]
class AttendanceApiService {
  final Dio _dio;

  AttendanceApiService(this._dio);

  /// Submit presensi dengan validasi token QR & GPS Geofence (POST /attendance/check-in)
  // TODO: Hubungkan ke backend saat endpoint siap
  Future<ApiResponse<dynamic>> checkIn({
    required String qrToken,
    required double latitude,
    required double longitude,
  }) async {
    throw UnimplementedError('Endpoint POST ${ApiEndpoints.attendanceCheckIn} masih dalam rencana pengembangan backend.');
  }

  /// Status kehadiran peserta di satu kegiatan (GET /attendance/my/:workshopId)
  // TODO: PROPOSED endpoint
  Future<ApiResponse<dynamic>> getMyAttendance(String workshopId) async {
    throw UnimplementedError('Endpoint GET ${ApiEndpoints.myAttendance(workshopId)} masih dalam rencana pengembangan backend.');
  }
}

