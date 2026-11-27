import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/data/participant_store.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/workshop_widgets.dart';
import '../data/presensi_qr.dart';
import '../providers/attendance_provider.dart';
import 'online_attendance_screen.dart';

/// Judul & penjelasan hasil presensi. Kunci = `state` dari backend
/// (attendance.service.js) ditambah `success`, `other-workshop`, `error`.
const _scanResults = {
  'success': (
    'Presensi berhasil',
    'Kehadiran Anda sudah tercatat dan tervalidasi.'
  ),
  'invalid-code': (
    'Kode presensi tidak valid',
    'Kode salah atau sudah kedaluwarsa. Pindai QR terbaru yang ditampilkan panitia.'
  ),
  'other-workshop': (
    'QR Code tidak sesuai',
    'QR ini untuk kegiatan lain. Pastikan Anda memindai QR kegiatan ini.'
  ),
  'outside-radius': (
    'Di luar lokasi',
    'Anda perlu berada di area kegiatan untuk melakukan presensi.'
  ),
  'location-denied': (
    'Lokasi tidak tersedia',
    'Izinkan akses lokasi dan aktifkan GPS untuk melanjutkan presensi.'
  ),
  'not-open': (
    'Presensi belum dibuka',
    'Tunggu hingga panitia membuka sesi presensi.'
  ),
  'closed': (
    'Presensi telah ditutup',
    'Hubungi panitia untuk informasi lebih lanjut.'
  ),
  'not-registered': (
    'Peserta belum terdaftar',
    'Daftar kegiatan terlebih dahulu untuk melakukan presensi.'
  ),
  'waiting-list': (
    'Masih dalam waiting list',
    'Presensi dapat dilakukan setelah Anda mendapat kursi.'
  ),
  'cancelled': ('Kegiatan dibatalkan', 'Kegiatan ini dibatalkan oleh panitia.'),
  'present': (
    'Presensi sudah tercatat',
    'Kehadiran untuk hari ini sudah tersimpan.'
  ),
  'pending': (
    'Presensi sudah terkirim',
    'Presensi Anda untuk hari ini sedang menunggu verifikasi panitia.'
  ),
  'error': ('Presensi gagal', 'Terjadi kesalahan. Silakan coba lagi.'),
};

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key, required this.workshopId, this.dayId});
  final String workshopId;
  final String? dayId;
  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  final _code = TextEditingController();
  String? _result;
  String? _detail;
  bool _submitting = false;
  bool _camera = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(participantStoreProvider);
    final w = state.workshopById(widget.workshopId);
    if (w == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Presensi Kegiatan')),
          body: state.loading
              ? const Center(child: CircularProgressIndicator())
              : const AppEmptyState(
                  icon: Icons.qr_code_scanner,
                  title: 'Kegiatan tidak ditemukan',
                  message: 'Buka presensi melalui halaman Kegiatan Saya.'));
    }
    if (widget.dayId == null && w.days.length > 1) {
      return AttendanceStatusScreen(workshopId: w.id);
    }
    final matches =
        w.days.where((day) => day.id == (widget.dayId ?? w.days.first.id));
    if (matches.isEmpty) {
      return Scaffold(
          appBar: AppBar(title: const Text('Presensi Kegiatan')),
          body: const AppEmptyState(
              icon: Icons.event_busy_outlined,
              title: 'Jadwal tidak ditemukan',
              message: 'Pilih hari melalui daftar presensi harian.'));
    }
    final day = matches.first;
    if (w.delivery == WorkshopDelivery.online) {
      return OnlineAttendanceScreen(
          key: ValueKey('${w.id}/${day.id}'), workshop: w, day: day);
    }
    final registration = state.registrationFor(w.id);
    final record = registration?.attendanceFor(day);
    final alreadyRecorded = record?.status == AttendanceStatus.present;
    final canSubmit = registration != null &&
        !registration.isWaiting &&
        day.window == AttendanceWindow.open &&
        (record?.status.canSubmit ?? false);
    if (_result != null) return _resultView(context, w, day);
    return Scaffold(
        backgroundColor: const Color(0xFF0F1F17),
        appBar: AppBar(
            title: const Text('Presensi Kegiatan'),
            backgroundColor: const Color(0xFF0F1F17),
            foregroundColor: Colors.white,
            titleTextStyle: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
            child: Column(children: [
              StatusBadge(alreadyRecorded
                  ? 'Sudah Hadir'
                  : day.window == AttendanceWindow.open
                      ? 'Presensi aktif'
                      : day.window == AttendanceWindow.notOpen
                          ? 'Belum Dibuka'
                          : 'Presensi Ditutup'),
              const SizedBox(height: 10),
              Text(w.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.4)),
              const SizedBox(height: 7),
              Text(
                  'Hari ke-${w.days.indexOf(day) + 1} • ${day.date}\n${day.time}',
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFFA7C5B2))),
              const SizedBox(height: 20),
              Container(
                  height: 320,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      color: const Color(0xFF263B2E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0x26FFFFFF))),
                  child: _camera && canSubmit && !_submitting
                      ? MobileScanner(onDetect: (capture) {
                          for (final barcode in capture.barcodes) {
                            final value = barcode.rawValue;
                            if (value != null && value.trim().isNotEmpty) {
                              setState(() => _camera = false);
                              _submit(w, value);
                              return;
                            }
                          }
                        })
                      : Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(children: [
                            const Row(children: [
                              Icon(Icons.videocam_outlined,
                                  size: 18, color: Color(0xFFD1FAE5)),
                              SizedBox(width: 6),
                              Text('Pemindai QR',
                                  style: TextStyle(
                                      fontSize: 11, color: Color(0xFFD1FAE5)))
                            ]),
                            const Spacer(),
                            Container(
                                width: 194,
                                height: 194,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xFF86EFAC),
                                        width: 3),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      const Icon(Icons.qr_code_scanner_rounded,
                                          size: 60, color: Color(0x66FFFFFF)),
                                      if (_submitting)
                                        const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: LinearProgressIndicator(
                                                color: Color(0xFF4ADE80),
                                                backgroundColor:
                                                    Colors.transparent,
                                                minHeight: 2))
                                    ])),
                            const Spacer(),
                            Text(
                                _submitting
                                    ? 'Memvalidasi kode, waktu, dan lokasi...'
                                    : 'Arahkan kamera ke QR Code yang ditampilkan panitia',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xFFDBE8DF))),
                          ]))),
              const SizedBox(height: 12),
              InfoNote(
                  w.hasGeofence
                      ? 'Lokasi perangkat dipakai sekali untuk memastikan Anda berada di area kegiatan.'
                      : 'Presensi divalidasi dengan kode dari panitia.',
                  icon: Icons.shield_outlined),
              if (!canSubmit && !alreadyRecorded) ...[
                const SizedBox(height: 12),
                InfoNote(
                    registration == null
                        ? 'Daftar kegiatan terlebih dahulu untuk melakukan presensi.'
                        : registration.isWaiting
                            ? 'Anda masih dalam waiting list. Presensi dapat dilakukan setelah mendapat kursi.'
                            : record?.status == AttendanceStatus.submitted
                                ? 'Presensi hari ini sudah terkirim dan menunggu verifikasi.'
                                : day.window == AttendanceWindow.notOpen
                                    ? 'Presensi hari ini belum dibuka oleh panitia.'
                                    : 'Presensi hari ini telah ditutup oleh panitia.',
                    warning: true),
              ],
              if (record?.status == AttendanceStatus.rejected &&
                  record?.reason != null) ...[
                const SizedBox(height: 12),
                InfoNote('Presensi sebelumnya ditolak: ${record!.reason}',
                    warning: true),
              ],
              const SizedBox(height: 17),
              AppButton(_camera ? 'Tutup Kamera' : 'Pindai QR dengan Kamera',
                  icon: Icons.qr_code_scanner,
                  onPressed: !canSubmit || _submitting
                      ? null
                      : () => setState(() => _camera = !_camera)),
              const SizedBox(height: 17),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Atau masukkan kode presensi',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDBE8DF)))),
              const SizedBox(height: 7),
              TextField(
                  controller: _code,
                  enabled: canSubmit && !_submitting,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                      hintText: 'Kode 6 karakter',
                      hintStyle: TextStyle(
                          color: Color(0xFF7C9A86),
                          fontSize: 12,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w400),
                      fillColor: Color(0xFF1E3226)),
                  onSubmitted: (value) => _submit(w, value)),
              const SizedBox(height: 12),
              AppButton(_submitting ? 'Memproses...' : 'Kirim Presensi',
                  icon: Icons.check_circle_outline,
                  onPressed: !canSubmit || _submitting
                      ? null
                      : () => _submit(w, _code.text)),
            ])));
  }

  Future<void> _submit(Workshop w, String scanned) async {
    if (_submitting) return;
    final qr = PresensiQr.parse(scanned);
    if (qr.code.isEmpty) {
      showMessage(context, 'Masukkan kode presensi dari panitia.',
          error: true);
      return;
    }
    if (qr.workshop.isNotEmpty && qr.workshop != w.id) {
      setState(() {
        _result = 'other-workshop';
        _detail = null;
      });
      return;
    }
    setState(() => _submitting = true);
    String result = 'success';
    String? detail;
    try {
      DevicePosition? position;
      if (w.hasGeofence) {
        position = await ref.read(devicePositionProvider)();
      }
      await ref
          .read(participantStoreProvider.notifier)
          .checkIn(w.id, code: qr.code, position: position);
    } on LocationUnavailable catch (e) {
      result = 'location-denied';
      detail = e.message;
    } on ApiException catch (e) {
      result = _scanResults.containsKey(e.state) ? e.state! : 'error';
      detail = e.message;
    } catch (_) {
      result = 'location-denied';
      detail = 'Lokasi perangkat tidak dapat dibaca. Coba lagi di area terbuka.';
    }
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _result = result;
      _detail = detail;
      if (result == 'success') _code.clear();
    });
  }

  Widget _resultView(BuildContext context, Workshop w, WorkshopDay day) {
    final success = _result == 'success';
    final (title, message) = _scanResults[_result] ?? _scanResults['error']!;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Hasil Presensi')),
        body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 55, 24, 30),
            child: Column(children: [
              CircleAvatar(
                  radius: 38,
                  backgroundColor:
                      success ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                  child: Icon(
                      success ? Icons.check_rounded : Icons.priority_high_rounded,
                      size: 36,
                      color: success ? AppColors.green : AppColors.red)),
              const SizedBox(height: 25),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.8)),
              const SizedBox(height: 9),
              Text(_detail ?? message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.muted)),
              const SizedBox(height: 28),
              SurfaceCard(
                  child:
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(w.title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 15),
                DetailRow(
                    icon: Icons.calendar_month_outlined,
                    label: 'Hari ke-${w.days.indexOf(day) + 1}',
                    value: day.date),
                const SizedBox(height: 13),
                DetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Lokasi',
                    value: w.location,
                    detail: w.room.isEmpty ? null : w.room)
              ])),
              const SizedBox(height: 20),
              AppButton('Lihat Presensi Harian',
                  secondary: true,
                  onPressed: () => context.push('/attendance/status/${w.id}')),
              const SizedBox(height: 10),
              if (!success) ...[
                AppButton('Coba Lagi',
                    onPressed: () => setState(() {
                          _result = null;
                          _detail = null;
                        })),
                const SizedBox(height: 10)
              ],
              AppButton('Kembali ke Kegiatan Saya',
                  secondary: !success,
                  onPressed: () => context.go('/registrations')),
            ])));
  }
}

class AttendanceStatusScreen extends ConsumerWidget {
  const AttendanceStatusScreen({super.key, required this.workshopId});
  final String workshopId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(participantStoreProvider);
    final r = state.registrationFor(workshopId);
    final w = state.workshopById(workshopId);
    final present = r?.attendance == AttendanceStatus.present;
    return Scaffold(
        appBar: AppBar(title: const Text('Status Kehadiran')),
        body: RefreshIndicator(
            onRefresh: ref.read(participantStoreProvider.notifier).refresh,
            child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  SurfaceCard(
                      child: Column(children: [
                    CircleAvatar(
                        radius: 29,
                        backgroundColor: present
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFF1F5F9),
                        child: Icon(
                            present
                                ? Icons.check_circle_outline
                                : Icons.schedule_outlined,
                            color: present ? AppColors.green : AppColors.muted,
                            size: 30)),
                    const SizedBox(height: 12),
                    const Text('Status Kehadiran Anda',
                        style: TextStyle(fontSize: 11, color: AppColors.muted)),
                    const SizedBox(height: 4),
                    Text(r?.attendanceLabel ?? 'Belum Terdaftar',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    const Text('Tarik ke bawah untuk memperbarui status',
                        style: TextStyle(fontSize: 11, color: AppColors.muted))
                  ])),
                  const SizedBox(height: 18),
                  if (w != null)
                    SurfaceCard(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          StatusBadge(w.kind),
                          const SizedBox(height: 10),
                          Text(w.title,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 18),
                          DetailRow(
                              icon: Icons.calendar_month_outlined,
                              label: 'Tanggal',
                              value: w.date),
                          const SizedBox(height: 14),
                          if (w.delivery == WorkshopDelivery.online)
                            const InfoNote(Workshop.onlineLinkNotice,
                                icon: Icons.link_outlined)
                          else
                            DetailRow(
                                icon: Icons.location_on_outlined,
                                label: 'Lokasi',
                                value: w.location),
                        ])),
                  if (w != null) ...[
                    const SizedBox(height: 22),
                    SectionHeading('Presensi Harian',
                        caption: '${w.days.length} hari'),
                    InfoNote(w.delivery == WorkshopDelivery.online
                        ? 'Unggah screenshot keikutsertaan untuk setiap hari. Bukti diperiksa panitia secara terpisah.'
                        : 'Pindai QR di lokasi pada setiap hari kegiatan yang Anda ikuti.'),
                    const SizedBox(height: 14),
                    for (var index = 0; index < w.days.length; index++) ...[
                      _dayCard(context, w, r, w.days[index], index + 1),
                      const SizedBox(height: 12),
                    ],
                  ],
                ])));
  }

  Widget _dayCard(BuildContext context, Workshop w, Registration? r,
      WorkshopDay day, int number) {
    final record = r?.attendanceFor(day);
    final status = record?.status ?? AttendanceStatus.pending;
    final canCheckIn = r != null &&
        !r.isWaiting &&
        status.canSubmit &&
        day.window == AttendanceWindow.open;
    final label = r == null
        ? 'Belum Terdaftar'
        : status == AttendanceStatus.pending &&
                day.window == AttendanceWindow.notOpen
            ? 'Belum Dibuka'
            : status.label;
    return SurfaceCard(
        key: ValueKey('attendance-${day.id}'),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('Hari ke-$number',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                StatusBadge(label,
                    tone: status == AttendanceStatus.present
                        ? BadgeTone.green
                        : status == AttendanceStatus.absent ||
                                status == AttendanceStatus.rejected
                            ? BadgeTone.red
                            : BadgeTone.amber),
              ]),
          const SizedBox(height: 10),
          Text(day.date,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Text(day.time,
              style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          if (day.window == AttendanceWindow.closed) ...[
            const SizedBox(height: 8),
            const Text('Sesi presensi ditutup',
                style: TextStyle(fontSize: 11, color: AppColors.muted)),
          ],
          if (record?.reason != null) ...[
            const SizedBox(height: 8),
            InfoNote('Alasan penolakan: ${record!.reason}', warning: true),
          ],
          if (record?.evidenceUrl != null) ...[
            const SizedBox(height: 12),
            Image.network(record!.evidenceUrl!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.contain,
                cacheWidth: 800,
                semanticLabel: 'Bukti kehadiran hari ke-$number',
                errorBuilder: (_, __, ___) => const SizedBox.shrink()),
          ],
          if (record?.evidenceName != null) ...[
            const SizedBox(height: 6),
            Text(record!.evidenceName!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ],
          if (canCheckIn) ...[
            const SizedBox(height: 14),
            AppButton(
                w.delivery == WorkshopDelivery.online
                    ? (status == AttendanceStatus.rejected
                        ? 'Unggah Ulang Screenshot'
                        : 'Unggah Screenshot')
                    : 'Pindai QR',
                compact: true,
                icon: w.delivery == WorkshopDelivery.online
                    ? Icons.upload_file_outlined
                    : Icons.qr_code_scanner,
                onPressed: () =>
                    context.push('/attendance?workshop=${w.id}&day=${day.id}')),
          ],
        ]));
  }
}
