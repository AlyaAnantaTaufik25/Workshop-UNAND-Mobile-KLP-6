import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/demo/preview_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/workshop_widgets.dart';
import '../../workshops/widgets/workshop_card.dart';

class MyRegistrationsScreen extends ConsumerWidget {
  const MyRegistrationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(previewProvider);
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
              title: const Text('Kegiatan Saya'),
              bottom: const TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.muted,
                  indicatorColor: AppColors.primary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700),
                  tabs: [
                    Tab(text: 'Akan Datang'),
                    Tab(text: 'Berlangsung'),
                    Tab(text: 'Selesai')
                  ])),
          body: TabBarView(
              children: WorkshopPhase.values.map((phase) {
            final registrations = state.registrations
                .where((r) => findWorkshop(r.workshopId)?.phase == phase)
                .toList();
            if (registrations.isEmpty) {
              return SingleChildScrollView(
                  child: AppEmptyState(
                      icon: Icons.calendar_month_outlined,
                      title: 'Belum ada kegiatan',
                      message: phase == WorkshopPhase.upcoming
                          ? 'Belum ada kegiatan yang akan datang. Temukan kegiatan menarik untuk diikuti.'
                          : 'Tidak ada kegiatan pada kategori ini.',
                      action: AppButton('Cari Kegiatan',
                          onPressed: () => context.go('/workshops'))));
            }
            return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: registrations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final r = registrations[index];
                  final w = findWorkshop(r.workshopId)!;
                  return SurfaceCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child:
                                      WorkshopImage(w, width: 86, height: 105)),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Wrap(spacing: 8, runSpacing: 5, children: [
                                      StatusBadge(w.kind),
                                      WorkshopVenueBadge(w),
                                    ]),
                                    const SizedBox(height: 7),
                                    Text(w.title,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            height: 1.4,
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 7),
                                    Text(w.shortDate,
                                        style: const TextStyle(
                                            fontSize: 9,
                                            color: AppColors.muted)),
                                    if (w.delivery ==
                                        WorkshopDelivery.online) ...[
                                      const SizedBox(height: 4),
                                      Text(w.location,
                                          style: const TextStyle(
                                              fontSize: 9,
                                              color: AppColors.muted)),
                                    ],
                                  ]))
                            ]),
                        const SizedBox(height: 13),
                        const Divider(),
                        const SizedBox(height: 11),
                        const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Status Pendaftaran',
                                  style: TextStyle(
                                      fontSize: 9, color: AppColors.muted)),
                              StatusBadge('Terdaftar')
                            ]),
                        const SizedBox(height: 8),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Status Kehadiran',
                                  style: TextStyle(
                                      fontSize: 9, color: AppColors.muted)),
                              StatusBadge(r.attendanceLabel,
                                  tone: r.attendance == AttendanceStatus.pending
                                      ? BadgeTone.amber
                                      : r.attendance == AttendanceStatus.absent
                                          ? BadgeTone.red
                                          : BadgeTone.green)
                            ]),
                        const SizedBox(height: 11),
                        const Divider(),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(
                              child: AppButton('Lihat Detail',
                                  secondary: true,
                                  compact: true,
                                  onPressed: () =>
                                      context.push('/workshops/${w.id}'))),
                          if (w.attendanceOpen &&
                              r.attendance == AttendanceStatus.pending) ...[
                            const SizedBox(width: 8),
                            Expanded(
                                child: AppButton('Presensi Sekarang',
                                    compact: true,
                                    icon: Icons.qr_code_scanner,
                                    onPressed: () => context
                                        .push('/attendance?workshop=${w.id}')))
                          ]
                        ]),
                        if (r.attendance != AttendanceStatus.pending)
                          TextButton(
                              onPressed: () =>
                                  context.push('/attendance/status/${w.id}'),
                              child: const Text('Lihat Status Kehadiran',
                                  style: TextStyle(fontSize: 10))),
                      ]));
                });
          }).toList()),
        ));
  }
}
