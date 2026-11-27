/// Format tanggal Bahasa Indonesia tanpa dependensi tambahan.
class IdDate {
  IdDate._();

  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', //
    'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];
  static const _days = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];

  /// Mengurai tanggal ISO `YYYY-MM-DD` (tanpa zona waktu) menjadi DateTime lokal.
  static DateTime? parse(String? iso) {
    if (iso == null || iso.length < 10) return null;
    final parts = iso.substring(0, 10).split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  /// `2026-05-18`
  static String iso(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// `Senin, 18 Mei 2026`
  static String long(DateTime date) =>
      '${_days[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]} ${date.year}';

  /// `Mei`, `Jun` — tiga huruf awal nama bulan
  static String shortMonth(DateTime date) =>
      _months[date.month - 1].substring(0, 3);

  /// `18 Mei 2026`
  static String medium(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  /// `18 Mei 2026` atau `18–20 Mei 2026` atau `30 Mei – 2 Jun 2026`
  static String shortRange(DateTime start, DateTime end) {
    String mon(DateTime d) => _months[d.month - 1].substring(0, 3);
    if (!end.isAfter(start)) return '${start.day} ${mon(start)} ${start.year}';
    if (start.year == end.year && start.month == end.month) {
      return '${start.day}–${end.day} ${mon(start)} ${start.year}';
    }
    if (start.year == end.year) {
      return '${start.day} ${mon(start)} – ${end.day} ${mon(end)} ${end.year}';
    }
    return '${start.day} ${mon(start)} ${start.year} – ${end.day} ${mon(end)} ${end.year}';
  }

  /// Daftar tanggal dari [start] hingga [end] (inklusif), maksimal [limit] hari.
  static List<DateTime> daysBetween(DateTime start, DateTime end,
      {int limit = 31}) {
    final days = <DateTime>[];
    var current = start;
    while (!current.isAfter(end) && days.length < limit) {
      days.add(current);
      current = DateTime(current.year, current.month, current.day + 1);
    }
    return days.isEmpty ? [start] : days;
  }
}
