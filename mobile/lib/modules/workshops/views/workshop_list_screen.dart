import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Layar Katalog Workshop Peserta (Placeholder Inisiasi Awal)
class WorkshopListScreen extends StatelessWidget {
  const WorkshopListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Workshop UNAND'),
        actions: [
          IconButton(
            icon: const Icon(Icons.network_check_rounded),
            tooltip: 'Cek Server',
            onPressed: () => context.push('/health'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_note_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Katalog Workshop',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Rencana Pengembangan: Daftar workshop aktif, pencarian, dan kuota pendaftaran peserta.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

