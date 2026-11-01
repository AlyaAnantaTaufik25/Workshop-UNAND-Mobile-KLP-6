import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Layar Login Peserta (Placeholder Inisiasi Awal)
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Peserta'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.school_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'SIM Workshop UNAND',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Aplikasi Khusus Peserta',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade900,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'Email UNAND / Umum',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const TextField(
                        enabled: false,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Placeholder
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Fitur login masih dalam rencana pengembangan backend.',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Masuk (Rencana Pengembangan)'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Tombol langsung ke Cek Koneksi Server
              OutlinedButton.icon(
                onPressed: () => context.push('/health'),
                icon: const Icon(Icons.network_check_rounded),
                label: const Text('Cek Koneksi ke Server Backend'),
              ),
              const SizedBox(height: 12),

              // Tombol langsung masuk ke Beranda Peserta untuk eksplorasi placeholder
              TextButton(
                onPressed: () => context.go('/workshops'),
                child: const Text('Masuk sebagai Tamu (Eksplorasi Antarmuka)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

