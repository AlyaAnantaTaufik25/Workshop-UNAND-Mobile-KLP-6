import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/demo/preview_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/workshop_widgets.dart';
import '../providers/screenshot_provider.dart';

class OnlineAttendanceScreen extends ConsumerStatefulWidget {
  const OnlineAttendanceScreen(
      {super.key, required this.workshop, required this.day});
  final Workshop workshop;
  final WorkshopDay day;

  @override
  ConsumerState<OnlineAttendanceScreen> createState() =>
      _OnlineAttendanceScreenState();
}

class _OnlineAttendanceScreenState
    extends ConsumerState<OnlineAttendanceScreen> {
  ScreenshotEvidence? _evidence;
  String? _error;
  bool _picking = false;

  @override
  Widget build(BuildContext context) {
    final w = widget.workshop;
    final day = widget.day;
    final registration = ref.watch(previewProvider).registrationFor(w.id);
    final record = registration?.attendanceFor(day);
    final submitted = record?.status == AttendanceStatus.submitted;
    final recorded = submitted || record?.status == AttendanceStatus.present;
    final canSubmit = registration != null &&
        day.window == AttendanceWindow.open &&
        !recorded;
    final evidence = record?.evidence ?? _evidence;
    final dayNumber = w.days.indexOf(day) + 1;
    return Scaffold(
      appBar: AppBar(title: const Text('Presensi Online')),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const StatusBadge('Online • Unggah Screenshot'),
            const SizedBox(height: 14),
            Text(w.title,
                style:
                    const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
            const SizedBox(height: 18),
            SurfaceCard(
                child: Column(children: [
              DetailRow(
                  icon: Icons.calendar_month_outlined,
                  label: 'Hari ke-$dayNumber dari ${w.days.length}',
                  value: day.date),
              const SizedBox(height: 14),
              DetailRow(
                  icon: Icons.schedule_outlined,
                  label: 'Waktu',
                  value: day.time),
            ])),
            const SizedBox(height: 16),
            if (recorded) ...[
              InfoNote(
                  submitted
                      ? 'Screenshot untuk hari ke-$dayNumber berhasil disimpan. Menunggu verifikasi panitia.'
                      : 'Kehadiran hari ke-$dayNumber sudah tercatat.',
                  icon: Icons.check_circle_outline),
            ] else if (!canSubmit) ...[
              InfoNote(
                  registration == null
                      ? 'Daftar kegiatan terlebih dahulu untuk melakukan presensi.'
                      : day.window == AttendanceWindow.notOpen
                          ? 'Presensi hari ini belum dibuka oleh panitia.'
                          : 'Presensi hari ini telah ditutup oleh panitia.',
                  warning: true),
            ] else ...[
              const InfoNote(
                  'Unggah screenshot keikutsertaan Anda pada pertemuan online sesuai hari yang dipilih. Pastikan nama dan kegiatan terlihat jelas.'),
            ],
            const SizedBox(height: 22),
            const SectionHeading('Bukti Kehadiran'),
            if (evidence != null)
              SurfaceCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(evidence.bytes,
                            height: 190,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            cacheWidth: 1000,
                            semanticLabel:
                                'Screenshot bukti kehadiran hari ke-$dayNumber')),
                    const SizedBox(height: 10),
                    Text(evidence.name,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2),
                  ]))
            else
              const SurfaceCard(
                  child: Padding(
                padding: EdgeInsets.symmetric(vertical: 25),
                child: Column(children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      size: 42, color: AppColors.green),
                  SizedBox(height: 12),
                  Text('Belum ada screenshot', style: TextStyle(fontSize: 13)),
                  SizedBox(height: 6),
                  Text('PNG atau JPG, maksimal 5 MB',
                      style: TextStyle(fontSize: 11, color: AppColors.muted)),
                ]),
              )),
            if (_error != null) ...[
              const SizedBox(height: 12),
              InfoNote(_error!, warning: true),
            ],
            if (canSubmit) ...[
              const SizedBox(height: 16),
              AppButton(
                  _picking
                      ? 'Membaca Screenshot...'
                      : evidence == null
                          ? 'Pilih Screenshot'
                          : 'Ganti Screenshot',
                  secondary: true,
                  icon: Icons.upload_file_outlined,
                  onPressed: _picking ? null : _pick),
              const SizedBox(height: 12),
              AppButton('Kirim Presensi',
                  icon: Icons.send_outlined,
                  onPressed: _evidence == null || _picking ? null : _submit),
            ],
            const SizedBox(height: 12),
            const Text(
                'Pratinjau: screenshot tersimpan sementara dan belum dikirim ke panitia.',
                style: TextStyle(fontSize: 10, color: AppColors.muted)),
            const SizedBox(height: 16),
            AppButton('Lihat Presensi Harian',
                secondary: true,
                onPressed: () => context.push('/attendance/status/${w.id}')),
          ])),
    );
  }

  Future<void> _pick() async {
    setState(() {
      _picking = true;
      _error = null;
    });
    try {
      final evidence = await ref.read(screenshotPickerProvider)();
      if (evidence == null) return;
      if (mounted) setState(() => _evidence = evidence);
    } on FormatException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
            () => _error = 'Screenshot gagal dibuka. Silakan pilih ulang.');
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _submit() {
    final saved = ref
        .read(previewProvider.notifier)
        .checkIn(widget.workshop.id, dayId: widget.day.id, evidence: _evidence);
    if (!saved) {
      setState(() => _error =
          'Presensi tidak dapat dikirim. Periksa status presensi hari ini.');
    }
  }
}
