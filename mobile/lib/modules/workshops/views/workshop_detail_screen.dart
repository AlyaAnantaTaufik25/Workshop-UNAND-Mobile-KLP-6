import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/participant_store.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/workshop_widgets.dart';
import '../widgets/workshop_card.dart';

class WorkshopDetailScreen extends ConsumerWidget {
  const WorkshopDetailScreen({super.key, required this.workshopId});
  final String workshopId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(participantStoreProvider);
    final w = state.workshopById(workshopId);
    if (w == null && state.loading) {
      return Scaffold(
          appBar: AppBar(title: const Text('Detail Kegiatan')),
          body: const Center(child: CircularProgressIndicator()));
    }
    if (w == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Detail Kegiatan')),
          body: const AppEmptyState(
              icon: Icons.event_busy_outlined,
              title: 'Kegiatan tidak ditemukan',
              message: 'Silakan kembali ke daftar kegiatan.'));
    }
    final registration = state.registrationFor(workshopId);
    final registered = registration != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kegiatan')),
      bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border))),
          child: SafeArea(
              top: false,
              child: AppButton(
                  registered
                      ? 'Lihat di Kegiatan Saya'
                      : switch (w.status) {
                          WorkshopStatus.open => 'Daftar Kegiatan',
                          WorkshopStatus.waitlist => 'Daftar Waiting List',
                          _ => w.registrationLabel,
                        },
                  onPressed: registered
                      ? () => context.go('/registrations')
                      : w.canRegister
                          ? () => _register(context, ref, w)
                          : null))),
      body: SingleChildScrollView(
          child: Column(children: [
        Stack(children: [
          WorkshopImage(w, height: 245, width: double.infinity),
          Positioned(
              bottom: 16,
              left: 20,
              right: 20,
              child: Wrap(spacing: 8, runSpacing: 5, children: [
                StatusBadge(w.kind),
                WorkshopVenueBadge(w),
              ]))
        ]),
        Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (registration != null)
                StatusBadge(registration.statusLabel,
                    tone: registration.isWaiting
                        ? BadgeTone.amber
                        : BadgeTone.green)
              else if (w.status != WorkshopStatus.open || w.capacity == null)
                StatusBadge(w.registrationLabel,
                    tone: w.status == WorkshopStatus.full || w.cancelled
                        ? BadgeTone.red
                        : w.status == WorkshopStatus.waitlist
                            ? BadgeTone.amber
                            : BadgeTone.gray),
              const SizedBox(height: 11),
              Text(w.title,
                  style: const TextStyle(
                      fontSize: 21,
                      color: AppColors.heading,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -.3,
                      height: 1.4)),
              const SizedBox(height: 6),
              ThemeTag(w.theme.isEmpty ? w.kind : w.theme),
              _section(
                  'Informasi Pelaksanaan',
                  Column(children: [
                    DetailRow(
                        icon: Icons.calendar_month_outlined,
                        label: 'Tanggal',
                        value: w.date),
                    const SizedBox(height: 17),
                    DetailRow(
                        icon: Icons.schedule_outlined,
                        label: 'Waktu',
                        value: w.time),
                    const SizedBox(height: 17),
                    if (w.delivery == WorkshopDelivery.online &&
                        registration != null &&
                        !registration.isWaiting &&
                        w.meetingUrl != null) ...[
                      DetailRow(
                          icon: Icons.link_outlined,
                          label: 'Tautan Kegiatan',
                          value: w.meetingUrl!),
                    ] else if (w.delivery == WorkshopDelivery.online)
                      const InfoNote(Workshop.onlineLinkNotice,
                          icon: Icons.link_outlined)
                    else
                      DetailRow(
                          icon: Icons.location_on_outlined,
                          label: 'Lokasi',
                          value: w.location,
                          detail: w.room),
                    const SizedBox(height: 17),
                    DetailRow(
                        icon: Icons.groups_outlined,
                        label: 'Target Peserta',
                        value: w.target),
                  ])),
              _section(
                  'Jadwal & Presensi Harian',
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoNote(w.delivery == WorkshopDelivery.online
                            ? 'Presensi dilakukan dengan mengunggah screenshot pada setiap hari kegiatan.'
                            : 'Presensi dilakukan dengan memindai QR di lokasi pada setiap hari kegiatan.'),
                        const SizedBox(height: 14),
                        for (var index = 0; index < w.days.length; index++) ...[
                          DetailRow(
                              icon: Icons.event_outlined,
                              label: 'Hari ke-${index + 1}',
                              value: w.days[index].date,
                              detail: w.days[index].time),
                          const SizedBox(height: 14),
                        ],
                        if (registered)
                          AppButton('Lihat Presensi Harian',
                              secondary: true,
                              onPressed: () =>
                                  context.push('/attendance/status/${w.id}')),
                      ])),
              _section(
                  'Tentang Kegiatan',
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(w.description,
                            style: const TextStyle(
                                fontSize: 12,
                                height: 1.7,
                                color: Color(0xFF475569))),
                        const SizedBox(height: 17),
                        SurfaceCard(
                            padding: const EdgeInsets.all(13),
                            child: Row(children: [
                              CircleAvatar(
                                  radius: 22,
                                  backgroundColor: AppColors.green,
                                  child: Text(w.speaker.substring(0, 1),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800))),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    const Text('Narasumber',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.muted)),
                                    Text(w.speaker,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700)),
                                    Text(w.organizer,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.muted))
                                  ]))
                            ])),
                      ])),
              if (w.benefits.isNotEmpty)
              _section(
                  'Manfaat yang Didapatkan',
                  Column(
                      children: w.benefits
                          .map((b) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(children: [
                                const Icon(Icons.check_circle_outline,
                                    color: AppColors.green, size: 18),
                                const SizedBox(width: 9),
                                Expanded(
                                    child: Text(b,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF475569))))
                              ])))
                          .toList())),
              _section(
                  'Informasi Pendaftaran',
                  // .peserta-registration-box: panel tint + sisa kursi
                  Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: AppColors.paleGreen,
                          border: Border.all(color: const Color(0xFFCFE4D4)),
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Periode pendaftaran',
                                style: TextStyle(
                                    fontSize: 11, color: AppColors.muted)),
                            const SizedBox(height: 3),
                            Text(w.registrationPeriod,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.heading,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 14),
                            const Text('Kuota',
                                style: TextStyle(
                                    fontSize: 11, color: AppColors.muted)),
                            const SizedBox(height: 3),
                            Text(
                                w.capacity == null
                                    ? 'Pendaftaran terbuka tanpa batas kuota'
                                    : (w.remaining ?? 0) > 0
                                        ? '${w.remaining} dari ${w.capacity} kursi tersisa'
                                        : 'Kuota ${w.capacity} kursi sudah penuh',
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.heading,
                                    fontWeight: FontWeight.w700)),
                            if (w.capacity != null && w.capacity! > 0) ...[
                              const SizedBox(height: 10),
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(99),
                                  child: LinearProgressIndicator(
                                      value: (1 -
                                              (w.remaining ?? 0) / w.capacity!)
                                          .clamp(0.0, 1.0),
                                      minHeight: 6,
                                      backgroundColor: const Color(0xFFD7E8DB),
                                      color: AppColors.green)),
                              const SizedBox(height: 6),
                              Text(
                                  '${w.capacity! - (w.remaining ?? 0)} dari ${w.capacity} kursi terisi',
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.muted)),
                            ],
                          ]))),
            ])),
      ])),
    );
  }

  /// Kartu konten seperti `.peserta-detail-copy` di portal web
  Widget _section(String title, Widget child) => Padding(
      padding: const EdgeInsets.only(top: 14),
      child: SurfaceCard(
          padding: const EdgeInsets.all(18),
          child: SizedBox(
              width: double.infinity,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.heading,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 14),
                    child
                  ]))));

  Future<void> _register(
      BuildContext context, WidgetRef ref, Workshop w) async {
    final confirm = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
        builder: (sheetContext) => SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Expanded(
                            child: Text('Konfirmasi Pendaftaran',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800))),
                        IconButton(
                            tooltip: 'Tutup',
                            onPressed: () => Navigator.pop(sheetContext, false),
                            icon: const Icon(Icons.close, size: 20))
                      ]),
                      const Divider(),
                      const SizedBox(height: 20),
                      Text(w.title,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text('${w.shortDate} • ${w.time}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.muted)),
                      const SizedBox(height: 15),
                      Text(
                          w.status == WorkshopStatus.waitlist
                              ? 'Kuota sudah penuh. Anda akan masuk waiting list dan mendapat kursi sesuai urutan bila ada peserta yang batal.'
                              : 'Pastikan Anda dapat hadir sesuai jadwal kegiatan.',
                          style:
                              const TextStyle(fontSize: 12, color: AppColors.muted)),
                      const SizedBox(height: 22),
                      Row(children: [
                        Expanded(
                            child: AppButton('Batal',
                                secondary: true,
                                onPressed: () =>
                                    Navigator.pop(sheetContext, false))),
                        const SizedBox(width: 10),
                        Expanded(
                            child: AppButton('Ya, Daftar',
                                onPressed: () =>
                                    Navigator.pop(sheetContext, true)))
                      ]),
                    ]))));
    if (confirm != true || !context.mounted) return;
    final Registration? registration;
    try {
      registration = await ref
          .read(participantStoreProvider.notifier)
          .registerWorkshop(w.id);
    } catch (e) {
      if (context.mounted) showMessage(context, errorMessage(e), error: true);
      return;
    }
    if (!context.mounted) return;
    final waiting = registration?.isWaiting ?? false;
    await showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.white,
        builder: (sheetContext) => SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const CircleAvatar(
                      radius: 34,
                      backgroundColor: Color(0xFFDCFCE7),
                      child: Icon(Icons.check_rounded,
                          color: AppColors.green, size: 32)),
                  const SizedBox(height: 18),
                  Text(waiting ? 'Masuk Waiting List' : 'Pendaftaran Berhasil',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Text(
                      waiting
                          ? 'Kuota ${w.title} sudah penuh. Anda berada di antrean${registration?.queue != null ? ' nomor ${registration!.queue}' : ''} dan otomatis mendapat kursi bila ada pembatalan.'
                          : 'Anda berhasil terdaftar pada ${w.title}.',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 22),
                  AppButton('Lihat Kegiatan Saya', onPressed: () {
                    Navigator.pop(sheetContext);
                    context.go('/registrations');
                  }),
                ]))));
  }
}
