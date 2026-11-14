import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/demo/preview_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/workshop_widgets.dart';
import 'online_attendance_screen.dart';

const _scanResults = {
  'success': (
    'Presensi berhasil',
    'Kehadiran Anda berhasil tercatat dalam simulasi ini.'
  ),
  'expired': (
    'QR Code kedaluwarsa',
    'Pindai QR Code terbaru yang ditampilkan panitia.'
  ),
  'invalid': (
    'QR Code tidak valid',
    'Pastikan Anda memindai QR Code untuk kegiatan ini.'
  ),
  'outside': (
    'Di luar lokasi',
    'Anda perlu berada di area kegiatan untuk melakukan presensi.'
  ),
  'denied': (
    'Izin lokasi ditolak',
    'Izinkan akses lokasi untuk melanjutkan presensi.'
  ),
  'not-open': (
    'Presensi belum dibuka',
    'Tunggu hingga panitia membuka sesi presensi.'
  ),
  'closed': (
    'Presensi telah ditutup',
    'Hubungi panitia untuk informasi lebih lanjut.'
  ),
  'unregistered': (
    'Peserta belum terdaftar',
    'Daftar kegiatan terlebih dahulu untuk melakukan presensi.'
  ),
  'recorded': (
    'Presensi sudah tercatat',
    'Kehadiran untuk hari ini sudah tersimpan.'
  ),
};

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen(
      {super.key, this.workshopId = 'kuliah-ai', this.dayId});
  final String workshopId;
  final String? dayId;
  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  String _selection = 'success';
  String? _result;
  bool _scanning = false;
  @override
  Widget build(BuildContext context) {
    final w = findWorkshop(widget.workshopId);
    if (w == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Presensi Kegiatan')),
          body: const AppEmptyState(
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
    final registration = ref.watch(previewProvider).registrationFor(w.id);
    final alreadyRecorded =
        registration?.attendanceFor(day).status == AttendanceStatus.present;
    if (_result != null) {
      final success = _result == 'success';
      final (title, message) = _scanResults[_result]!;
      return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(title: const Text('Hasil Presensi')),
          body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 55, 24, 30),
              child: Column(children: [
                CircleAvatar(
                    radius: 38,
                    backgroundColor: success
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFEE2E2),
                    child: Icon(
                        success
                            ? Icons.check_rounded
                            : Icons.priority_high_rounded,
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
                Text(message,
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 13, color: AppColors.muted)),
                const SizedBox(height: 28),
                SurfaceCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          value: w.location)
                    ])),
                const SizedBox(height: 20),
                AppButton('Lihat Presensi Harian',
                    secondary: true,
                    onPressed: () =>
                        context.push('/attendance/status/${w.id}')),
                const SizedBox(height: 10),
                if (!success) ...[
                  AppButton('Coba Lagi',
                      onPressed: () => setState(() => _result = null)),
                  const SizedBox(height: 10)
                ],
                AppButton('Kembali ke Kegiatan Saya',
                    secondary: !success,
                    onPressed: () => context.go('/registrations')),
              ])));
    }
    return Scaffold(
        backgroundColor: const Color(0xFF0F1F17),
        appBar: AppBar(
            title: const Text('Presensi Kegiatan'),
            backgroundColor: const Color(0xFF0F1F17),
            foregroundColor: Colors.white,
            titleTextStyle: const TextStyle(
                fontFamily: 'Inter',
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
                      const TextStyle(fontSize: 10, color: Color(0xFFA7C5B2))),
              const SizedBox(height: 20),
              Container(
                  height: 320,
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: const Color(0xFF263B2E),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0x26FFFFFF))),
                  child: Column(children: [
                    const Row(children: [
                      Icon(Icons.videocam_outlined,
                          size: 18, color: Color(0xFFD1FAE5)),
                      SizedBox(width: 6),
                      Text('Kamera simulasi',
                          style:
                              TextStyle(fontSize: 9, color: Color(0xFFD1FAE5)))
                    ]),
                    const Spacer(),
                    Container(
                        width: 194,
                        height: 194,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFF86EFAC), width: 3),
                            borderRadius: BorderRadius.circular(12)),
                        child: Stack(alignment: Alignment.center, children: [
                          const Icon(Icons.qr_code_scanner_rounded,
                              size: 60, color: Color(0x66FFFFFF)),
                          if (_scanning)
                            const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: LinearProgressIndicator(
                                    color: Color(0xFF4ADE80),
                                    backgroundColor: Colors.transparent,
                                    minHeight: 2))
                        ])),
                    const Spacer(),
                    Text(
                        _scanning
                            ? 'Memvalidasi QR, waktu, dan lokasi...'
                            : 'Arahkan kamera ke QR Code yang ditampilkan panitia',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 9, color: Color(0xFFDBE8DF))),
                  ])),
              const SizedBox(height: 12),
              const InfoNote(
                  'Simulasi pratinjau. Kamera dan lokasi perangkat tidak diakses.',
                  icon: Icons.shield_outlined),
              const SizedBox(height: 17),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Simulasikan hasil pemindaian',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDBE8DF)))),
              const SizedBox(height: 7),
              InputDecorator(
                decoration: const InputDecoration(fillColor: Color(0xFF1E3226)),
                child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                  value: _selection,
                  isDense: true,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1E3226),
                  style: const TextStyle(
                      color: Colors.white, fontFamily: 'Inter', fontSize: 12),
                  items: _scanResults.entries
                      .map((e) => DropdownMenuItem(
                          value: e.key, child: Text(e.value.$1)))
                      .toList(),
                  onChanged: _scanning
                      ? null
                      : (value) => setState(() => _selection = value!),
                )),
              ),
              const SizedBox(height: 17),
              AppButton(_scanning ? 'Sedang Memindai...' : 'Mulai Pindai',
                  icon: Icons.qr_code_scanner,
                  onPressed: _scanning ||
                          alreadyRecorded ||
                          registration == null ||
                          day.window != AttendanceWindow.open
                      ? null
                      : _scan),
            ])));
  }

  Future<void> _scan() async {
    setState(() => _scanning = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    var result = _selection;
    if (result == 'success') {
      final state = ref.read(previewProvider);
      if (state.registrationFor(widget.workshopId) == null) {
        result = 'unregistered';
      } else {
        final w = findWorkshop(widget.workshopId)!;
        final day = w.days
            .firstWhere((day) => day.id == (widget.dayId ?? w.days.first.id));
        if (day.window == AttendanceWindow.notOpen) {
          result = 'not-open';
        } else if (day.window == AttendanceWindow.closed) {
          result = 'closed';
        } else if (!ref
            .read(previewProvider.notifier)
            .checkIn(widget.workshopId, dayId: day.id)) {
          result = 'recorded';
        }
      }
    }
    setState(() {
      _scanning = false;
      _result = result;
    });
  }
}

class AttendanceStatusScreen extends ConsumerWidget {
  const AttendanceStatusScreen({super.key, required this.workshopId});
  final String workshopId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(previewProvider).registrationFor(workshopId);
    final w = findWorkshop(workshopId);
    final present = r?.attendance == AttendanceStatus.present;
    return Scaffold(
        appBar: AppBar(title: const Text('Status Kehadiran')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          SurfaceCard(
              child: Column(children: [
            CircleAvatar(
                radius: 29,
                backgroundColor:
                    present ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                child: Icon(
                    present
                        ? Icons.check_circle_outline
                        : Icons.schedule_outlined,
                    color: present ? AppColors.green : AppColors.muted,
                    size: 30)),
            const SizedBox(height: 12),
            const Text('Status Kehadiran Anda',
                style: TextStyle(fontSize: 10, color: AppColors.muted)),
            const SizedBox(height: 4),
            Text(r?.attendanceLabel ?? 'Belum Terdaftar',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text('Data presensi pada pratinjau aplikasi',
                style: TextStyle(fontSize: 10, color: AppColors.muted))
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
            SectionHeading('Presensi Harian', caption: '${w.days.length} hari'),
            InfoNote(w.delivery == WorkshopDelivery.online
                ? 'Unggah screenshot keikutsertaan untuk setiap hari. Bukti diperiksa panitia secara terpisah.'
                : 'Pindai QR di lokasi pada setiap hari kegiatan yang Anda ikuti.'),
            const SizedBox(height: 14),
            for (var index = 0; index < w.days.length; index++) ...[
              _dayCard(context, w, r, w.days[index], index + 1),
              const SizedBox(height: 12),
            ],
          ],
        ]));
  }

  Widget _dayCard(BuildContext context, Workshop w, PreviewRegistration? r,
      WorkshopDay day, int number) {
    final record = r?.attendanceFor(day);
    final status = record?.status ?? AttendanceStatus.pending;
    final canCheckIn = r != null &&
        status == AttendanceStatus.pending &&
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
                        : status == AttendanceStatus.absent
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
                style: TextStyle(fontSize: 10, color: AppColors.muted)),
          ],
          if (record?.evidence != null) ...[
            const SizedBox(height: 12),
            Image.memory(record!.evidence!.bytes,
                height: 120,
                width: double.infinity,
                fit: BoxFit.contain,
                cacheWidth: 800,
                semanticLabel: 'Bukti kehadiran hari ke-$number'),
            const SizedBox(height: 6),
            Text(record.evidence!.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ],
          if (canCheckIn) ...[
            const SizedBox(height: 14),
            AppButton(
                w.delivery == WorkshopDelivery.online
                    ? 'Unggah Screenshot'
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
