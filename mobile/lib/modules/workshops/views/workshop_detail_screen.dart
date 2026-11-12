import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/demo/preview_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/workshop_widgets.dart';
import '../widgets/workshop_card.dart';

class WorkshopDetailScreen extends ConsumerWidget {
  const WorkshopDetailScreen({super.key, required this.workshopId});
  final String workshopId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = findWorkshop(workshopId);
    if (w == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Detail Kegiatan')),
          body: const AppEmptyState(
              icon: Icons.event_busy_outlined,
              title: 'Kegiatan tidak ditemukan',
              message: 'Silakan kembali ke daftar kegiatan.'));
    }
    final registered =
        ref.watch(previewProvider).registrationFor(workshopId) != null;
    return Scaffold(
      backgroundColor: Colors.white,
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
                      : w.status == WorkshopStatus.full
                          ? 'Kuota Penuh'
                          : w.status == WorkshopStatus.closed
                              ? 'Pendaftaran Ditutup'
                              : 'Daftar Kegiatan',
                  onPressed: registered
                      ? () => context.go('/registrations')
                      : w.status == WorkshopStatus.open
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
              if (registered)
                const StatusBadge('Terdaftar')
              else if (w.status != WorkshopStatus.open || w.capacity == null)
                StatusBadge(
                    w.status == WorkshopStatus.full
                        ? 'Kuota Penuh'
                        : w.status == WorkshopStatus.closed
                            ? 'Pendaftaran Ditutup'
                            : 'Pendaftaran Terbuka',
                    tone: w.status == WorkshopStatus.full
                        ? BadgeTone.red
                        : BadgeTone.gray),
              const SizedBox(height: 11),
              Text(w.title,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.8,
                      height: 1.25)),
              const SizedBox(height: 7),
              Text(w.theme,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted)),
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
                    DetailRow(
                        icon: w.delivery == WorkshopDelivery.online
                            ? Icons.videocam_outlined
                            : Icons.location_on_outlined,
                        label: w.delivery == WorkshopDelivery.online
                            ? 'Platform'
                            : 'Lokasi',
                        value: w.location,
                        detail: w.room),
                    const SizedBox(height: 17),
                    DetailRow(
                        icon: Icons.groups_outlined,
                        label: 'Target Peserta',
                        value: w.target),
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
                                            fontSize: 9,
                                            color: AppColors.muted)),
                                    Text(w.speaker,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700)),
                                    Text(w.organizer,
                                        style: const TextStyle(
                                            fontSize: 9,
                                            color: AppColors.muted))
                                  ]))
                            ])),
                      ])),
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
                  Column(children: [
                    DetailRow(
                        icon: Icons.calendar_month_outlined,
                        label: 'Periode Pendaftaran',
                        value: w.registrationPeriod),
                    const SizedBox(height: 16),
                    DetailRow(
                        icon: Icons.groups_outlined,
                        label: 'Kuota',
                        value: w.capacity == null
                            ? 'Pendaftaran terbuka tanpa batas kuota'
                            : '${w.remaining} dari ${w.capacity} kursi tersisa')
                  ])),
            ])),
      ])),
    );
  }

  Widget _section(String title, Widget child) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 23),
      padding: const EdgeInsets.only(top: 23),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 15),
        child
      ]));

  Future<void> _register(
      BuildContext context, WidgetRef ref, Workshop w) async {
    final confirm = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
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
                      const Text(
                          'Pastikan Anda dapat hadir sesuai jadwal kegiatan.',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.muted)),
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
    ref.read(previewProvider.notifier).register(w.id);
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
                  const Text('Pendaftaran Berhasil',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Text('Anda berhasil terdaftar pada ${w.title}.',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 22),
                  AppButton('Lihat Kegiatan Saya', onPressed: () {
                    Navigator.pop(sheetContext);
                    context.go('/registrations');
                  }),
                ]))));
  }
}
