import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/data/participant_models.dart';
import '../../../core/network/api_call.dart';

/// Kegiatan beserta pendaftaran peserta yang sedang login (bila ada)
class WorkshopWithRegistration {
  const WorkshopWithRegistration(this.workshop, this.registration);
  final Workshop workshop;
  final Registration? registration;

  factory WorkshopWithRegistration.fromJson(dynamic data) {
    final json = jsonMap(data);
    final workshop = Workshop.fromJson(json);
    final mine = json['myRegistration'];
    return WorkshopWithRegistration(
        workshop, mine is Map ? Registration.fromJson(jsonMap(mine), workshop) : null);
  }
}

/// Service API Katalog Kegiatan Workshop
class WorkshopApiService {
  final Dio _dio;

  WorkshopApiService(this._dio);

  /// GET /workshops — kegiatan publik (+ `myRegistration` untuk peserta)
  Future<List<WorkshopWithRegistration>> getWorkshops({String? search}) =>
      apiCall(
        () => _dio.get(ApiEndpoints.workshops,
            queryParameters: {
              if (search != null && search.isNotEmpty) 'search': search
            }),
        (data) =>
            jsonList(data).map(WorkshopWithRegistration.fromJson).toList(),
      );

  /// GET /workshops/:idOrSlug
  Future<WorkshopWithRegistration> getWorkshopDetail(String idOrSlug) =>
      apiCall(() => _dio.get(ApiEndpoints.workshopDetail(idOrSlug)),
          WorkshopWithRegistration.fromJson);
}
