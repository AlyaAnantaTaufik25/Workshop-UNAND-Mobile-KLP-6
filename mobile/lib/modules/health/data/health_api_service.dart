import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/network/api_response.dart';
import '../models/health_model.dart';

class HealthApiService {
  final Dio _dio;

  HealthApiService(this._dio);

  /// Memeriksa status kesehatan server dan koneksi MySQL
  Future<ApiResponse<HealthData>> getHealth() async {
    try {
      final response = await _dio.get(ApiEndpoints.health);

      if (response.data is Map<String, dynamic>) {
        return ApiResponse.fromJson(
          response.data as Map<String, dynamic>,
          (data) => HealthData.fromJson(data as Map<String, dynamic>),
        );
      }

      throw const ApiException(message: 'Format respon server tidak valid');
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map<String, dynamic>) {
        final errorJson = e.response!.data as Map<String, dynamic>;
        throw ApiException(
          message: errorJson['message'] as String? ?? 'Terjadi kesalahan pada server',
          statusCode: e.response?.statusCode,
          errors: (errorJson['errors'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
        );
      }

      throw NetworkException(
        message: 'Tidak dapat menjangkau server di ${_dio.options.baseUrl}.\n'
            'Pastikan backend berjalan (npm run dev di port 5000) dan '
            'perangkat/emulator terhubung ke jaringan yang sama.\n\nDetail: ${e.message}',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Kesalahan tak terduga: $e');
    }
  }
}

