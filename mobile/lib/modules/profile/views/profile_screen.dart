import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Layar Profil Peserta (Placeholder Inisiasi Awal)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Peserta'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.person_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Profil Pengguna (Peserta)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Rencana Pengembangan: Manajemen data akun, riwayat keikutsertaan, ganti password, dan pengaturan akun.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => context.push('/health'),
                icon: const Icon(Icons.network_check_rounded),
                label: const Text('Cek Koneksi Server Backend'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.go('/login'),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Keluar / Kembali ke Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

