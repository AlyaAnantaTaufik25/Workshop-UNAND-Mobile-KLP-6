import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/participant_store.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/id_date.dart';
import '../../../core/widgets/workshop_widgets.dart';
import '../../workshops/widgets/workshop_card.dart';

class MyRegistrationsScreen extends ConsumerWidget {
  const MyRegistrationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(participantStoreProvider);
    final store = ref.read(participantStoreProvider.notifier);
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
              title: const PageTitle('Kegiatan Saya'),
              bottom: const TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.muted,
                  indicatorColor: AppColors.primary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                  tabs: [
                    Tab(text: 'Akan Datang'),
                    Tab(text: 'Berlangsung'),
                    Tab(text: 'Selesai')
                  ])),
          body: TabBarView(
              children: WorkshopPhase.values.map((phase) {
            final registrations = state.registrations.values
                .where((r) => r.workshop.phase == phase)
                .toList();
            if (state.loading && !state.loaded) {
              return const Center(child: CircularProgressIndicator());
            }
            if (registrations.isEmpty) {
              return RefreshIndicator(
                  onRefresh: store.refresh,
                  child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(children: [
                    if (state.error != null)
                      Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: LoadErrorBanner(state.error!,
                              onRetry: store.refresh)),
                    AppEmptyState(
                      icon: Icons.calendar_month_outlined,
                      title: 'Belum ada kegiatan',
                      message: phase == WorkshopPhase.upcoming
                          ? 'Belum ada kegiatan yang akan datang. Temukan kegiatan menarik untuk diikuti.'
                          : 'Tidak ada kegiatan pada kategori ini.',
                      action: AppButton('Cari Kegiatan',
                          onPressed: () => context.go('/workshops'))),
                  ])));
            }
            return RefreshIndicator(
                onRefresh: store.refresh,
                child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                itemCount: registrations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final r = registrations[index];
                  final w = r.workshop;
                  return SurfaceCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _dateBox(w),
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
                                            fontSize: 11,
                                            color: AppColors.muted)),
                                    if (w.delivery ==
                                        WorkshopDelivery.online) ...[
                                      const SizedBox(height: 4),
                                      const Text('Tautan tersedia H-1',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.muted)),
                                    ],
                                  ]))
                            ]),
                        const SizedBox(height: 13),
                        const Divider(),
                        const SizedBox(height: 11),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                  child: Text('Status Pendaftaran',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.muted))),
                              const SizedBox(width: 8),
                              StatusBadge(r.statusLabel,
                                  tone: r.isWaiting
                                      ? BadgeTone.amber
                                      : BadgeTone.green)
                            ]),
                        const SizedBox(height: 8),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                  child: Text('Status Kehadiran',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.muted))),
                              const SizedBox(width: 8),
                              StatusBadge(r.attendanceLabel,
                                  tone: r.isWaiting ||
                                          r.attendance ==
                                              AttendanceStatus.pending ||
                                          r.attendance ==
                                              AttendanceStatus.submitted
                                      ? BadgeTone.amber
                                      : r.attendance ==
                                                  AttendanceStatus.absent ||
                                              r.attendance ==
                                                  AttendanceStatus.rejected
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
                          if (r.canCheckIn) ...[
                            const SizedBox(width: 8),
                            Expanded(
                                child: AppButton('Presensi Sekarang',
                                    compact: true,
                                    icon: w.delivery == WorkshopDelivery.online
                                        ? Icons.upload_file_outlined
                                        : Icons.qr_code_scanner,
                                    onPressed: () => context
                                        .push('/attendance?workshop=${w.id}')))
                          ]
                        ]),
                        TextButton(
                            onPressed: () =>
                                context.push('/attendance/status/${w.id}'),
                            child: Text(
                                w.days.length > 1
                                    ? 'Lihat Presensi Harian'
                                    : 'Lihat Status Kehadiran',
                                style: const TextStyle(fontSize: 11))),
                        if (r.canCancel)
                          TextButton(
                              onPressed: () => _cancel(context, ref, r),
                              style: TextButton.styleFrom(
                                  foregroundColor: AppColors.red),
                              child: const Text('Batalkan Pendaftaran',
                                  style: TextStyle(fontSize: 11))),
                      ]));
                }));
          }).toList()),
        ));
  }

  /// `.peserta-datebox`: tanggal mulai kegiatan
  static Widget _dateBox(Workshop w) {
    final start = IdDate.parse(w.days.first.id) ?? DateTime.now();
    return DateBox(
        day: '${start.day}',
        month: IdDate.shortMonth(start),
        muted: w.phase == WorkshopPhase.finished);
  }

  Future<void> _cancel(
      BuildContext context, WidgetRef ref, Registration registration) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
                title: const Text('Batalkan pendaftaran?',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                content: Text(
                    'Kursi Anda pada "${registration.workshop.title}" akan diberikan ke peserta berikutnya.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Tidak')),
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Ya, Batalkan',
                          style: TextStyle(color: AppColors.red))),
                ]));
    if (confirmed != true || !context.mounted) return;
    try {
      await ref
          .read(participantStoreProvider.notifier)
          .cancelRegistration(registration.workshopId);
      if (context.mounted) showMessage(context, 'Pendaftaran dibatalkan.');
    } catch (e) {
      if (context.mounted) showMessage(context, errorMessage(e), error: true);
    }
  }
}
