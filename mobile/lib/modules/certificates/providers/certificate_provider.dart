import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../health/providers/health_provider.dart';
import '../data/certificate_api_service.dart';
import '../data/certificate_repository.dart';

final certificateApiServiceProvider = Provider<CertificateApiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return CertificateApiService(dioClient.dio);
});

final certificateRepositoryProvider = Provider<CertificateRepository>((ref) {
  final apiService = ref.watch(certificateApiServiceProvider);
  return CertificateRepository(apiService);
});

