import 'package:flutter/material.dart';

/// Layar Verifikasi Sertifikat Publik (Placeholder Inisiasi Awal)
class CertificateVerifyScreen extends StatelessWidget {
  const CertificateVerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Sertifikat'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Verifikasi Sertifikat',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Rencana Pengembangan: Input nomor seri sertifikat atau scan QR verifikasi untuk memeriksa keaslian sertifikat secara publik.',
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

