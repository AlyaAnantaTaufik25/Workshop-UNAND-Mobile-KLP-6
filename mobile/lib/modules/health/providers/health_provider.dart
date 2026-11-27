import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/network_providers.dart';
import '../data/health_api_service.dart';
import '../data/health_repository.dart';
import '../models/health_model.dart';

export '../../../core/network/network_providers.dart'
    show sessionStorageProvider, dioClientProvider;

final healthApiServiceProvider = Provider<HealthApiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return HealthApiService(dioClient.dio);
});

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  final apiService = ref.watch(healthApiServiceProvider);
  return HealthRepository(apiService);
});

// StateNotifier untuk mengontrol aksi pemeriksaan kesehatan
class HealthStateNotifier
    extends StateNotifier<AsyncValue<ApiResponse<HealthData>?>> {
  final HealthRepository _repository;

  HealthStateNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> checkServerHealth() async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.checkHealth();
      state = AsyncValue.data(response);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final healthStateNotifierProvider = StateNotifierProvider<HealthStateNotifier,
    AsyncValue<ApiResponse<HealthData>?>>((ref) {
  final repository = ref.watch(healthRepositoryProvider);
  return HealthStateNotifier(repository);
});
