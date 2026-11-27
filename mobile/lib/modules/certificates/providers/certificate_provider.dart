import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/network/network_providers.dart';
import '../data/certificate_api_service.dart';

final certificateApiServiceProvider = Provider<CertificateApiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return CertificateApiService(dioClient.dio);
});

/// Menyimpan PDF sertifikat ke penyimpanan aplikasi lalu membukanya dengan
/// penampil PDF perangkat. Mengembalikan lokasi berkas.
/// Dapat di-override pada pengujian.
final certificateFileSaverProvider =
    Provider<Future<String> Function(String fileName, Uint8List bytes)>((ref) {
  return (fileName, bytes) async {
    if (kIsWeb) {
      throw UnsupportedError(
          'Unduhan PDF belum didukung pada versi web aplikasi. Unduh melalui portal web peserta.');
    }
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}${Platform.pathSeparator}$fileName');
    await file.writeAsBytes(bytes, flush: true);
    await OpenFilex.open(file.path, type: 'application/pdf');
    return file.path;
  };
});
