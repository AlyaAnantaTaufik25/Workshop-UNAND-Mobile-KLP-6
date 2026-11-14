import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/demo/preview_data.dart';

const maxScreenshotBytes = 5 * 1024 * 1024;

final screenshotPickerProvider =
    Provider<Future<ScreenshotEvidence?> Function()>((ref) {
  return () async {
    final file = await openFile(acceptedTypeGroups: const [
      XTypeGroup(
          label: 'Screenshot (PNG/JPG)',
          extensions: ['png', 'jpg', 'jpeg'],
          mimeTypes: ['image/png', 'image/jpeg'],
          uniformTypeIdentifiers: ['public.png', 'public.jpeg']),
    ]);
    return file == null ? null : readScreenshot(file);
  };
});

Future<ScreenshotEvidence> readScreenshot(XFile file) async {
  final extension = file.name.split('.').last.toLowerCase();
  if (!['png', 'jpg', 'jpeg'].contains(extension)) {
    throw const FormatException('Pilih screenshot berformat PNG atau JPG.');
  }
  if (await file.length() > maxScreenshotBytes) {
    throw const FormatException('Ukuran screenshot maksimal 5 MB.');
  }
  final bytes = await file.readAsBytes();
  if (bytes.isEmpty || bytes.length > maxScreenshotBytes) {
    throw const FormatException('Screenshot kosong atau melebihi 5 MB.');
  }
  final png = bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4e &&
      bytes[3] == 0x47 &&
      bytes[4] == 0x0d &&
      bytes[5] == 0x0a &&
      bytes[6] == 0x1a &&
      bytes[7] == 0x0a;
  final jpeg = bytes.length >= 3 &&
      bytes[0] == 0xff &&
      bytes[1] == 0xd8 &&
      bytes[2] == 0xff;
  if ((extension == 'png' && !png) || (extension != 'png' && !jpeg)) {
    throw const FormatException('Isi file harus berupa gambar PNG atau JPG.');
  }
  try {
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 1200);
    try {
      final frame = await codec.getNextFrame();
      frame.image.dispose();
    } finally {
      codec.dispose();
    }
  } catch (_) {
    throw const FormatException(
        'Gambar tidak dapat dibaca. Pilih screenshot lain.');
  }
  return ScreenshotEvidence(name: file.name, bytes: bytes);
}
