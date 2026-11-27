import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/network_providers.dart';
import '../data/notification_api_service.dart';

final notificationApiServiceProvider = Provider<NotificationApiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return NotificationApiService(dioClient.dio);
});
