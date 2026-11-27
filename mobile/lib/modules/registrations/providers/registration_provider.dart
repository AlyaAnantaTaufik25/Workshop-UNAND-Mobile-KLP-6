import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/network_providers.dart';
import '../data/registration_api_service.dart';

final registrationApiServiceProvider = Provider<RegistrationApiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return RegistrationApiService(dioClient.dio);
});
