import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../health/providers/health_provider.dart';
import '../data/workshop_api_service.dart';
import '../data/workshop_repository.dart';

final workshopApiServiceProvider = Provider<WorkshopApiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return WorkshopApiService(dioClient.dio);
});

final workshopRepositoryProvider = Provider<WorkshopRepository>((ref) {
  final apiService = ref.watch(workshopApiServiceProvider);
  return WorkshopRepository(apiService);
});

