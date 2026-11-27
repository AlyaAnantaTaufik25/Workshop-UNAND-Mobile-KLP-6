import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/data/participant_models.dart';
import '../../../core/network/api_call.dart';

/// Service API Notifikasi (lonceng)
class NotificationApiService {
  final Dio _dio;

  NotificationApiService(this._dio);

  /// GET /notifications — 30 notifikasi terbaru
  Future<List<AppNotification>> getNotifications() => apiCall(
        () => _dio.get(ApiEndpoints.notifications),
        (data) => jsonList(data)
            .map((e) => AppNotification.fromJson(jsonMap(e)))
            .toList(),
      );

  /// PATCH /notifications/read — tandai satu ([id]) atau semua dibaca
  Future<void> markRead({int? id}) => apiCall(
        () => _dio.patch(ApiEndpoints.notificationsRead,
            data: {if (id != null) 'id': id}),
        (_) {},
      );
}
