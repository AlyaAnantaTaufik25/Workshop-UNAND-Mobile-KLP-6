import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/session_storage.dart';
import 'dio_client.dart';

/// Penanda global apakah peserta sedang masuk.
/// Dipakai router (redirect) dan diturunkan menjadi `false` oleh
/// AuthInterceptor saat server menolak token (HTTP 401).
final signedIn = ValueNotifier<bool>(false);

final sessionStorageProvider = Provider<SessionStorage>((ref) {
  return SessionStorage();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(sessionStorageProvider);
  return DioClient(
    sessionStorage: storage,
    onSessionExpired: () => signedIn.value = false,
  );
});
