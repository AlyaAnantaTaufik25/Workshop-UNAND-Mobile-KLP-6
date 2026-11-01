import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/env.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../providers/health_provider.dart';

/// Layar Cek Koneksi Server (Endpoint aktif: GET /api/v1/health)
class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});

  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen> {
  @override
  void initState() {
    super.initState();
    // Jalankan pemeriksaan saat layar pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthStateNotifierProvider.notifier).checkServerHealth();
    });
  }

  @override
  Widget build(BuildContext context) {
    final healthState = ref.watch(healthStateNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cek Koneksi Server'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Info Konfigurasi
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.settings_ethernet_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Konfigurasi Jaringan',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildInfoRow('Base URL:', Env.apiBaseUrl),
                    const SizedBox(height: 8),
                    _buildInfoRow('Endpoint:', '/api/v1/health'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Konten Hasil Cek Koneksi
            healthState.when(
              data: (apiResponse) {
                if (apiResponse == null) {
                  return const SizedBox.shrink();
                }

                final data = apiResponse.data;
                final isDbConnected = data?.database?.status == 'connected';

                return Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Koneksi Server Berhasil!',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.green.shade900,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          apiResponse.message,
                          style: TextStyle(color: Colors.green.shade800),
                        ),
                        const Divider(height: 24),
                        if (data != null) ...[
                          _buildInfoRow('Aplikasi:', data.app),
                          const SizedBox(height: 6),
                          _buildInfoRow('Versi:', data.version),
                          const SizedBox(height: 6),
                          _buildInfoRow('Environment:', data.environment),
                          const SizedBox(height: 6),
                          _buildInfoRow('Waktu Server:', data.timestamp),
                          const SizedBox(height: 6),
                          _buildInfoRow('Uptime:', '${data.uptimeSeconds} detik'),
                          const Divider(height: 20),
                          Row(
                            children: [
                              Icon(
                                isDbConnected
                                    ? Icons.storage_rounded
                                    : Icons.warning_amber_rounded,
                                color: isDbConnected ? Colors.teal : Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Database MySQL: ${data.database?.status ?? "unknown"}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDbConnected
                                      ? Colors.teal.shade900
                                      : Colors.orange.shade900,
                                ),
                              ),
                            ],
                          ),
                          if (data.database?.message != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              data.database!.message,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDbConnected
                                    ? Colors.teal.shade700
                                    : Colors.orange.shade800,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: LoadingView(
                    message: 'Menghubungi server backend UNAND...\n(Mohon tunggu)',
                  ),
                ),
              ),
              error: (error, _) {
                String message = 'Gagal terhubung ke backend';
                List<String> errors = [];

                if (error is ApiException) {
                  message = error.message;
                  errors = error.errors;
                } else {
                  message = error.toString();
                }

                return Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ErrorView(
                      message: message,
                      errors: errors,
                      onRetry: () {
                        ref
                            .read(healthStateNotifierProvider.notifier)
                            .checkServerHealth();
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(healthStateNotifierProvider.notifier).checkServerHealth();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Cek Ulang Koneksi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}

