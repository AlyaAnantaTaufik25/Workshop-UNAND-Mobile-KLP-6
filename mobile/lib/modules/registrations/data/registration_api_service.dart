import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_call.dart';
import '../../workshops/data/workshop_api_service.dart';

/// Service API Pendaftaran Workshop Peserta
class RegistrationApiService {
  final Dio _dio;

  RegistrationApiService(this._dio);

  /// POST /registrations — mendaftar (otomatis masuk waiting list bila kuota
  /// penuh). Mengembalikan detail kegiatan terbaru beserta pendaftaran saya.
  Future<WorkshopWithRegistration> registerToWorkshop(String workshopId) =>
      apiCall(
        () => _dio
            .post(ApiEndpoints.registrations, data: {'workshopId': workshopId}),
        WorkshopWithRegistration.fromJson,
      );

  /// PATCH /registrations/:id/cancel — membatalkan pendaftaran
  Future<WorkshopWithRegistration> cancelRegistration(int registrationId) =>
      apiCall(
        () => _dio.patch(ApiEndpoints.cancelRegistration(registrationId)),
        WorkshopWithRegistration.fromJson,
      );
}
