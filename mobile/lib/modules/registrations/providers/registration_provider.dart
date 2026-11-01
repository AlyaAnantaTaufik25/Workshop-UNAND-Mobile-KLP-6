import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../health/providers/health_provider.dart';
import '../data/registration_api_service.dart';
import '../data/registration_repository.dart';

final registrationApiServiceProvider = Provider<RegistrationApiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return RegistrationApiService(dioClient.dio);
});

final registrationRepositoryProvider = Provider<RegistrationRepository>((ref) {
  final apiService = ref.watch(registrationApiServiceProvider);
  return RegistrationRepository(apiService);
});

