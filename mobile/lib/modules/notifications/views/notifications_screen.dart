import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/participant_store.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/workshop_widgets.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(participantStoreProvider);
    final store = ref.read(participantStoreProvider.notifier);
    final notifications = state.notifications;
    return Scaffold(
        appBar: AppBar(title: const Text('Notifikasi'), actions: [
          TextButton(
              onPressed: state.unread == 0 ? null : () => store.markRead(null),
              child: const SizedBox(
                  width: 64,
                  child: Text('Tandai semua dibaca',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11))))
        ]),
        body: RefreshIndicator(
            onRefresh: store.refresh,
            child: notifications.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                        AppEmptyState(
                            icon: Icons.notifications_none_rounded,
                            title: 'Belum ada notifikasi',
                            message:
                                'Informasi pendaftaran, pengingat kegiatan, dan sertifikat akan muncul di sini.')
                      ])
                : ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 30),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 9),
            itemBuilder: (context, index) {
              final n = notifications[index];
              return Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      color: n.read ? Colors.white : const Color(0xFFF1FAF3),
                      border: Border.all(
                          color: n.read
                              ? AppColors.border
                              : const Color(0xFFCFE7D5)),
                      borderRadius: BorderRadius.circular(8)),
                  child: Column(children: [
                    InkWell(
                        onTap: () {
                          if (!n.read) store.markRead(n.id);
                          context.go(n.route);
                        },
                        child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: AppColors.paleGreen,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Icon(
                                          n.certificate
                                              ? Icons.workspace_premium_outlined
                                              : n.title
                                                      .toLowerCase()
                                                      .contains('pengingat')
                                                  ? Icons.schedule_outlined
                                                  : Icons.notifications_none,
                                          color: AppColors.primary,
                                          size: 21)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Row(children: [
                                          Expanded(
                                              child: Text(n.title,
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700))),
                                          if (!n.read)
                                            const CircleAvatar(
                                                radius: 3.5,
                                                backgroundColor:
                                                    AppColors.green)
                                        ]),
                                        const SizedBox(height: 5),
                                        Text(n.message,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                height: 1.5,
                                                color: Color(0xFF475569))),
                                        const SizedBox(height: 7),
                                        Text(n.time,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF94A3B8)))
                                      ])),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.chevron_right,
                                      color: Color(0xFF94A3B8), size: 18),
                                ]))),
                    if (!n.read)
                      Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                              onPressed: () => store.markRead(n.id),
                              icon: const Icon(Icons.done_all, size: 14),
                              label: const Text('Tandai dibaca',
                                  style: TextStyle(fontSize: 11)))),
                  ]));
            })));
  }
}
