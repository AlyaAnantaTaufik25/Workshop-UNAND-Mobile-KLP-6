import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/network_providers.dart';
import '../data/workshop_api_service.dart';

final workshopApiServiceProvider = Provider<WorkshopApiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return WorkshopApiService(dioClient.dio);
});
