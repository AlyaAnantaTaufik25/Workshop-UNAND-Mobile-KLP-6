import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/demo/preview_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/workshop_widgets.dart';
import '../widgets/workshop_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(previewProvider);
    final profile = state.profile ?? ParticipantProfile.student;
    final query = _search.text.trim().toLowerCase();
    final results = previewWorkshops
        .where((w) =>
            (_category == 'Semua' || w.kind == _category) &&
            w.title.toLowerCase().contains(query))
        .toList();
    final filtered = query.isNotEmpty || _category != 'Semua';
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
          Container(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.paddingOf(context).top + 18, 20, 28),
              decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(22))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const UnandBrand(compact: true, onDark: true),
                          Row(children: [
                            IconButton(
                                tooltip: 'Buka notifikasi',
                                color: Colors.white,
                                onPressed: () => context.push('/notifications'),
                                icon: Badge(
                                    isLabelVisible: state.unread > 0,
                                    label: Text('${state.unread}',
                                        style: const TextStyle(fontSize: 9)),
                                    child: const Icon(
                                        Icons.notifications_none_rounded,
                                        size: 22))),
                            const SizedBox(width: 6),
                            Semantics(
                                label: 'Buka profil',
                                button: true,
                                child: InkWell(
                                    onTap: () => context.go('/profile'),
                                    borderRadius: BorderRadius.circular(30),
                                    child: CircleAvatar(
                                        radius: 18.5,
                                        backgroundColor: Colors.white,
                                        child: Text(
                                            profile.name.substring(0, 1),
                                            style: const TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 13,
                                                fontWeight:
                                                    FontWeight.w800))))),
                          ]),
                        ]),
                    const SizedBox(height: 25),
                    Text('Halo, ${profile.name.split(' ').first}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFBBF7D0))),
                    const SizedBox(height: 5),
                    const SizedBox(
                        width: 330,
                        child: Text(
                            'Temukan kegiatan untuk mengembangkan potensimu.',
                            style: TextStyle(
                                fontSize: 29,
                                fontWeight: FontWeight.w800,
                                height: 1.18,
                                letterSpacing: -1,
                                color: Colors.white))),
                    const SizedBox(height: 22),
                    TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 11),
                        decoration: InputDecoration(
                            hintText:
                                'Cari workshop, seminar, atau kuliah umum',
                            hintStyle: const TextStyle(
                                fontSize: 11, color: AppColors.muted),
                            prefixIcon: const Icon(Icons.search_rounded,
                                size: 19, color: AppColors.muted),
                            suffixIcon: query.isNotEmpty
                                ? IconButton(
                                    tooltip: 'Hapus pencarian',
                                    onPressed: () => setState(_search.clear),
                                    icon: const Icon(Icons.close, size: 17))
                                : null,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none))),
                  ])),
          const SizedBox(height: 18),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                  children: ['Semua', 'Workshop', 'Seminar', 'Kuliah Umum']
                      .map((c) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                              label: Text(c),
                              selected: _category == c,
                              showCheckmark: false,
                              onSelected: (_) => setState(() => _category = c),
                              labelStyle: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _category == c
                                      ? Colors.white
                                      : AppColors.muted),
                              selectedColor: AppColors.primary,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              side: BorderSide(
                                  color: _category == c
                                      ? AppColors.primary
                                      : AppColors.border),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8))))
                      .toList())),
          Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!filtered) ...[
                      const SectionHeading('Kegiatan Terdekat',
                          caption: 'Minggu ini'),
                      WorkshopCard(
                          workshop: previewWorkshops.first,
                          registered: state
                                  .registrationFor(previewWorkshops.first.id) !=
                              null,
                          onOpen: () => context
                              .push('/workshops/${previewWorkshops.first.id}')),
                      const SizedBox(height: 30),
                    ],
                    SectionHeading(
                        filtered ? 'Hasil Pencarian' : 'Semua Kegiatan',
                        caption: '${results.length} kegiatan'),
                    if (results.isEmpty)
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
                        padding: const EdgeInsets.only(bottom: 13),
                        child: WorkshopCard(
                            workshop: w,
                            compact: true,
                            registered: state.registrationFor(w.id) != null,
                            onOpen: () => context.push('/workshops/${w.id}')))),
                  ])),
        ])));
  }
}
