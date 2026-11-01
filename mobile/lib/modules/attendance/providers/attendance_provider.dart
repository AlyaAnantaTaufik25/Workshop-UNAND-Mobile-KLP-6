import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../health/providers/health_provider.dart';
import '../data/attendance_api_service.dart';
import '../data/attendance_repository.dart';

final attendanceApiServiceProvider = Provider<AttendanceApiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AttendanceApiService(dioClient.dio);
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final apiService = ref.watch(attendanceApiServiceProvider);
  return AttendanceRepository(apiService);
});

