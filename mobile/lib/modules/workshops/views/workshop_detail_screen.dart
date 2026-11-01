import 'package:flutter/material.dart';

/// Layar Detail Workshop (Placeholder Inisiasi Awal)
class WorkshopDetailScreen extends StatelessWidget {
  final String workshopId;

  const WorkshopDetailScreen({super.key, required this.workshopId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Workshop'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline_rounded, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Detail Workshop #$workshopId',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Rencana Pengembangan: Informasi ruangan/gedung, jadwal, narasumber, dan tombol pendaftaran.',
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

