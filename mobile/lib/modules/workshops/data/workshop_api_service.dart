import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_response.dart';

/// Service API Katalog Kegiatan Workshop [PLANNED]
class WorkshopApiService {
  final Dio _dio;

  WorkshopApiService(this._dio);

  /// Mengambil daftar workshop publik dengan pagination & filter
  // TODO: Hubungkan ke GET /api/v1/workshops saat endpoint selesai dikembangkan
  Future<ApiResponse<List<dynamic>>> getWorkshops({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    throw UnimplementedError('Endpoint GET ${ApiEndpoints.workshops} masih dalam rencana pengembangan backend.');
  }

  /// Mengambil detail satu workshop
  // TODO: Hubungkan ke GET /api/v1/workshops/:id
  Future<ApiResponse<dynamic>> getWorkshopDetail(String id) async {
    throw UnimplementedError('Endpoint GET ${ApiEndpoints.workshopDetail(id)} masih dalam rencana pengembangan backend.');
  }
}

