import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/participant_store.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/workshop_widgets.dart';
import '../widgets/workshop_card.dart';

/// Beranda peserta — mengikuti halaman Beranda & Cari Workshop di portal web:
/// sapaan, kartu statistik, kotak filter, lalu daftar kartu kegiatan.
class WorkshopListScreen extends ConsumerStatefulWidget {
  const WorkshopListScreen({super.key});
  @override
  ConsumerState<WorkshopListScreen> createState() => _WorkshopListScreenState();
}

class _WorkshopListScreenState extends ConsumerState<WorkshopListScreen> {
  final _search = TextEditingController();
  String _category = 'Semua';
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Sorotan: kegiatan terdekat yang masih bisa didaftari, atau yang sedang
  /// berlangsung bila tidak ada.
  static Workshop? _highlight(List<Workshop> workshops) {
    for (final w in workshops) {
      if (w.phase != WorkshopPhase.finished && w.canRegister) return w;
    }
    for (final w in workshops) {
      if (w.phase == WorkshopPhase.ongoing) return w;
    }
    return null;
  }

  static String _initials(String name) => name
      .split(' ')
      .where((s) => s.isNotEmpty)
      .take(2)
      .map((s) => s[0].toUpperCase())
      .join();

  static Widget _statGrid(List<Widget> tiles) {
    Widget row(Widget a, Widget b) => IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: a),
          const SizedBox(width: 10),
          Expanded(child: b),
        ]));
    return Column(children: [
      row(tiles[0], tiles[1]),
      const SizedBox(height: 10),
      row(tiles[2], tiles[3]),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(participantStoreProvider);
    final name = (state.profile?.name.trim().isNotEmpty ?? false)
        ? state.profile!.name.trim()
        : 'Peserta';
    final query = _search.text.trim().toLowerCase();
    final categories = [
      'Semua',
      ...{for (final w in state.workshops) w.kind}
    ];
    if (!categories.contains(_category)) _category = 'Semua';
    final results = state.workshops
        .where((w) =>
            (_category == 'Semua' || w.kind == _category) &&
            (w.title.toLowerCase().contains(query) ||
                w.theme.toLowerCase().contains(query)))
        .toList();
    final filtered = query.isNotEmpty || _category != 'Semua';
    final highlight = _highlight(state.workshops);
    final store = ref.read(participantStoreProvider.notifier);
    final registrations = state.registrations.values;
    final registered = registrations
        .where((r) => !r.isWaiting && r.workshop.phase != WorkshopPhase.finished)
        .length;
    final waiting = registrations.where((r) => r.isWaiting).length;
    final finished = registrations
        .where((r) => !r.isWaiting && r.workshop.phase == WorkshopPhase.finished)
        .length;

    return Scaffold(
        body: Column(children: [
      // Topbar seperti portal web: merek, lonceng notifikasi, avatar
      Container(
          padding: EdgeInsets.fromLTRB(
              18, MediaQuery.paddingOf(context).top + 10, 14, 10),
          decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(children: [
            const Expanded(
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: UnandBrand(compact: true))),
            IconButton(
                tooltip: 'Buka notifikasi',
                color: AppColors.text,
                onPressed: () => context.push('/notifications'),
                icon: Badge(
                    isLabelVisible: state.unread > 0,
                    backgroundColor: AppColors.green,
                    label: Text(state.unread > 9 ? '9+' : '${state.unread}',
                        style: const TextStyle(fontSize: 11)),
                    child: const Icon(Icons.notifications_none_rounded,
                        size: 22))),
            const SizedBox(width: 4),
            Semantics(
                label: 'Buka profil',
                button: true,
                child: InkWell(
                    onTap: () => context.go('/profile'),
                    customBorder: const CircleBorder(),
                    child: CircleAvatar(
                        radius: 19,
                        backgroundColor: AppColors.paleGreen,
                        child: Text(_initials(name),
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700))))),
          ])),
      Expanded(
          child: RefreshIndicator(
              onRefresh: store.refresh,
              child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Halo, ${name.split(' ').first}',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -.3,
                                color: AppColors.heading)),
                        const SizedBox(height: 4),
                        const Text(
                            'Ringkasan kegiatan, presensi, dan sertifikat Anda di Workshop UNAND.',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.muted)),
                        const SizedBox(height: 18),
                        // Kartu statistik 2x2 (.dash-grid-4); tinggi mengikuti isi
                        _statGrid([

                              StatTile(
                                  icon: Icons.event_available_outlined,
                                  label: 'Workshop terdaftar',
                                  value: registered,
                                  onTap: () => context.go('/registrations')),
                              StatTile(
                                  icon: Icons.hourglass_empty_rounded,
                                  label: 'Dalam waiting list',
                                  value: waiting,
                                  onTap: () => context.go('/registrations')),
                              StatTile(
                                  icon: Icons.check_circle_outline,
                                  label: 'Workshop selesai',
                                  value: finished,
                                  onTap: () => context.go('/registrations')),
                              StatTile(
                                  icon: Icons.workspace_premium_outlined,
                                  label: 'Sertifikat',
                                  value: state.certificates.length,
                                  onTap: () => context.go('/certificates')),
                                                    ]),
                        const SizedBox(height: 18),
                        // Kotak filter (.peserta-filterbar)
                        SurfaceCard(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextField(
                                      controller: _search,
                                      onChanged: (_) => setState(() {}),
                                      style: const TextStyle(fontSize: 13),
                                      decoration: InputDecoration(
                                          hintText:
                                              'Cari workshop, seminar, atau kuliah umum',
                                          prefixIcon: const Icon(
                                              Icons.search_rounded,
                                              size: 19),
                                          suffixIcon: query.isNotEmpty
                                              ? IconButton(
                                                  tooltip: 'Hapus pencarian',
                                                  onPressed: () =>
                                                      setState(_search.clear),
                                                  icon: const Icon(Icons.close,
                                                      size: 17))
                                              : null)),
                                  const SizedBox(height: 10),
                                  SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                          children: categories
                                              .map((c) => Padding(
                                                  padding: const EdgeInsets.only(
                                                      right: 8),
                                                  child: ChoiceChip(
                                                      label: Text(c),
                                                      selected: _category == c,
                                                      showCheckmark: false,
                                                      onSelected: (_) =>
                                                          setState(() =>
                                                              _category = c),
                                                      labelStyle: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: _category == c
                                                              ? Colors.white
                                                              : const Color(
                                                                  0xFF52605A)),
                                                      selectedColor:
                                                          AppColors.primary,
                                                      backgroundColor:
                                                          Colors.white,
                                                      side: BorderSide(
                                                          color: _category == c
                                                              ? AppColors.primary
                                                              : AppColors
                                                                  .inputBorder),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 4,
                                                          vertical: 6))))
                                              .toList())),
                                ])),
                        const SizedBox(height: 24),
                        if (state.error != null)
                          LoadErrorBanner(state.error!, onRetry: store.refresh),
                        if (state.loading && !state.loaded)
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child:
                                  Center(child: CircularProgressIndicator())),
                        if (!filtered && highlight != null) ...[
                          const SectionHeading('Kegiatan Terdekat',
                              caption: 'Segera diikuti'),
                          WorkshopCard(
                              workshop: highlight,
                              registered:
                                  state.registrationFor(highlight.id) != null,
                              onOpen: () =>
                                  context.push('/workshops/${highlight.id}')),
                          const SizedBox(height: 26),
                        ],
                        SectionHeading(
                            filtered ? 'Hasil Pencarian' : 'Semua Kegiatan',
                            caption: '${results.length} kegiatan'),
                        if (results.isEmpty && state.loaded)
                          AppEmptyState(
                              icon: Icons.search_rounded,
                              title: 'Kegiatan tidak ditemukan',
                              message:
                                  'Coba gunakan kata kunci atau jenis kegiatan yang berbeda.',
                              action: AppButton('Atur Ulang Filter',
                                  secondary: true,
                                  onPressed: () => setState(() {
                                        _search.clear();
                                        _category = 'Semua';
                                      }))),
                        ...results.map((w) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: WorkshopCard(
                                workshop: w,
                                compact: true,
                                registered: state.registrationFor(w.id) != null,
                                onOpen: () =>
                                    context.push('/workshops/${w.id}')))),
                      ])))),
    ]));
  }
}
