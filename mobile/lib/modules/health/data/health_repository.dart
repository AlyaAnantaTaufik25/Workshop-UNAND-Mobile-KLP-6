import '../../../core/network/api_response.dart';
import '../models/health_model.dart';
import 'health_api_service.dart';

class HealthRepository {
  final HealthApiService _apiService;

  HealthRepository(this._apiService);

  Future<ApiResponse<HealthData>> checkHealth() {
    return _apiService.getHealth();
  }
}

