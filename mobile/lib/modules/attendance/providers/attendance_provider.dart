import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/network/network_providers.dart';
import '../data/attendance_api_service.dart';

final attendanceApiServiceProvider = Provider<AttendanceApiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AttendanceApiService(dioClient.dio);
});

/// Posisi perangkat untuk validasi radius lokasi (geofence) presensi offline.
class DevicePosition {
  const DevicePosition(this.latitude, this.longitude);
  final double latitude, longitude;
}

/// Kegagalan membaca lokasi yang dijelaskan ke peserta
class LocationUnavailable implements Exception {
  const LocationUnavailable(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Mengambil lokasi perangkat (meminta izin bila perlu).
/// Dapat di-override pada pengujian.
final devicePositionProvider =
    Provider<Future<DevicePosition> Function()>((ref) {
  return () async {
    if (!kIsWeb && !await Geolocator.isLocationServiceEnabled()) {
      throw const LocationUnavailable(
          'Layanan lokasi (GPS) perangkat sedang mati. Aktifkan lalu coba lagi.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationUnavailable(
          'Izin lokasi ditolak. Izinkan akses lokasi untuk aplikasi ini agar presensi dapat divalidasi.');
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 20)),
    );
    return DevicePosition(position.latitude, position.longitude);
  };
});
