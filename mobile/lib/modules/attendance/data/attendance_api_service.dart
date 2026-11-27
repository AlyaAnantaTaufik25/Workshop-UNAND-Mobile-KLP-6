import 'dart:convert';

import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/data/participant_models.dart';
import '../../../core/network/api_call.dart';
import '../../workshops/data/workshop_api_service.dart';

/// Service API Presensi Kehadiran
class AttendanceApiService {
  final Dio _dio;

  AttendanceApiService(this._dio);

  /// Presensi offline: kode dari QR panitia + lokasi GPS (POST /attendance/check-in)
  ///
  /// Kegagalan dilempar sebagai `ApiException` dengan `state`:
  /// `invalid-code`, `outside-radius`, `location-denied`, `not-open`,
  /// `closed`, `not-registered`, `waiting-list`, `present`, `pending`.
  Future<WorkshopWithRegistration> checkIn({
    required String workshopId,
    String? code,
    double? latitude,
    double? longitude,
  }) =>
      apiCall(
        () => _dio.post(ApiEndpoints.attendanceCheckIn, data: {
          'workshopId': workshopId,
          if (code != null && code.isNotEmpty) 'code': code,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        }),
        WorkshopWithRegistration.fromJson,
      );

  /// Presensi online: unggah screenshot bukti (POST /attendance/upload).
  /// Status menjadi "Menunggu Verifikasi" sampai diperiksa panitia.
  Future<WorkshopWithRegistration> uploadEvidence({
    required String workshopId,
    required ScreenshotEvidence evidence,
  }) =>
      apiCall(
        () => _dio.post(ApiEndpoints.attendanceUpload, data: {
          'workshopId': workshopId,
          'fileName': evidence.name,
          'fileData':
              'data:${evidence.mimeType};base64,${base64Encode(evidence.bytes)}',
        }),
        WorkshopWithRegistration.fromJson,
      );
}
