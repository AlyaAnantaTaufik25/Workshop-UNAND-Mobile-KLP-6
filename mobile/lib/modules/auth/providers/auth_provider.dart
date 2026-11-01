import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../health/providers/health_provider.dart';
import '../data/auth_api_service.dart';
import '../data/auth_repository.dart';

final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthApiService(dioClient.dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.watch(authApiServiceProvider);
  final sessionStorage = ref.watch(sessionStorageProvider);
  return AuthRepository(apiService, sessionStorage);
});

// State autentikasi sederhana
class AuthNotifier extends StateNotifier<AsyncValue<bool>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AsyncValue.data(false)) {
    checkStatus();
  }

  Future<void> checkStatus() async {
    final isAuthenticated = await _repository.checkAuth();
    state = AsyncValue.data(isAuthenticated);
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _repository.logout();
    state = const AsyncValue.data(false);
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<bool>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

