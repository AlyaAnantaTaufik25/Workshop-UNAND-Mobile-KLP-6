/// Isi QR presensi yang ditampilkan panitia di portal web.
///
/// Portal web (frontend/src/utils/presensiQr.js) membuat QR berisi tautan
/// `https://<web>/peserta/workshop-saya?presensi=<slug>&kode=<TOKEN>`.
/// Peserta juga dapat mengetik kode 6 karakter yang tertera di bawah QR.
class PresensiQr {
  const PresensiQr({required this.code, this.workshop = ''});
  final String code;

  /// Slug kegiatan yang tertanam di QR (kosong bila kode diketik manual)
  final String workshop;

  factory PresensiQr.parse(String text) {
    final raw = text.trim();
    final uri = Uri.tryParse(raw);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return PresensiQr(
        code: (uri.queryParameters['kode'] ?? '').trim().toUpperCase(),
        workshop: uri.queryParameters['presensi'] ?? '',
      );
    }
    final code = raw.length > 128 ? raw.substring(0, 128) : raw;
    return PresensiQr(code: code.toUpperCase());
  }
}
