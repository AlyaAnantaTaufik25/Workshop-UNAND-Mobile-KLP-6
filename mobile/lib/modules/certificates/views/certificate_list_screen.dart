import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/demo/preview_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/workshop_widgets.dart';

class CertificateListScreen extends ConsumerWidget {
  const CertificateListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
      appBar: AppBar(title: const Text('Sertifikat')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const InfoNote(
            'Sertifikat tersedia setelah kehadiran Anda sah dan proses penerbitan selesai.',
            icon: Icons.workspace_premium_outlined),
        const SizedBox(height: 27),
        const SectionHeading('Sertifikat Tersedia', caption: '1'),
        _card(context, previewWorkshops[3], true),
        const SizedBox(height: 27),
        const SectionHeading('Belum Tersedia', caption: '2'),
        _card(context, previewWorkshops[2], false),
        const SizedBox(height: 12),
        _card(context, previewWorkshops[4], false),
      ]));
  Widget _card(BuildContext context, Workshop w, bool available) => SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
                color: AppColors.paleGreen,
                borderRadius: BorderRadius.circular(11)),
            child: const Icon(Icons.workspace_premium_outlined,
                color: AppColors.primary, size: 24)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 8, runSpacing: 5, children: [
            StatusBadge(w.kind),
            StatusBadge(available ? 'Tersedia' : 'Belum Tersedia',
                tone: available ? BadgeTone.green : BadgeTone.amber)
          ]),
          const SizedBox(height: 8),
          Text(w.title,
              style: const TextStyle(
                  fontSize: 12, height: 1.45, fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          Text(w.shortDate,
              style: const TextStyle(fontSize: 9, color: AppColors.muted)),
          if (!available) ...[
            const SizedBox(height: 7),
            const Text('Menunggu validasi kehadiran dan penerbitan.',
                style: TextStyle(fontSize: 9, color: AppColors.amber))
          ],
          const SizedBox(height: 11),
          AppButton('Lihat Detail',
              secondary: true,
              compact: true,
              onPressed: () => context.push('/certificates/${w.id}')),
        ])),
      ]));
}

class CertificateDetailScreen extends ConsumerWidget {
  const CertificateDetailScreen({super.key, required this.workshopId});
  final String workshopId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = findWorkshop(workshopId);
    final state = ref.watch(previewProvider);
    final available = workshopId == 'karya-ilmiah';
    final corrected = state.corrections.contains(workshopId);
    if (w == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Detail Sertifikat')),
          body: const AppEmptyState(
              icon: Icons.workspace_premium_outlined,
              title: 'Sertifikat tidak ditemukan',
              message: 'Silakan kembali ke daftar sertifikat.'));
    }
    return Scaffold(
        appBar: AppBar(title: const Text('Detail Sertifikat')),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              StatusBadge(available ? 'Tersedia' : 'Belum Tersedia',
                  tone: available ? BadgeTone.green : BadgeTone.amber),
              const SizedBox(height: 10),
              Text(w.title,
                  style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      letterSpacing: -.5)),
              const SizedBox(height: 6),
              Text(w.shortDate,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              const SizedBox(height: 20),
              Stack(children: [
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: const Color(0xFFF1F5F9), width: 8)),
                    child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF86A991))),
                        child: Column(children: [
                          const UnandLogo(size: 48),
                          const SizedBox(height: 6),
                          const Text('UNIVERSITAS ANDALAS',
                              style: TextStyle(
                                  fontSize: 7,
                                  letterSpacing: 1.8,
                                  color: AppColors.primary)),
                          const SizedBox(height: 5),
                          const Text('SERTIFIKAT',
                              style: TextStyle(
                                  fontSize: 25,
                                  letterSpacing: 2,
                                  fontFamily: 'serif',
                                  color: AppColors.primary)),
                          const SizedBox(height: 12),
                          const Text('Diberikan kepada',
                              style: TextStyle(
                                  fontSize: 7, color: AppColors.muted)),
                          const SizedBox(height: 4),
                          Text(
                              state.profile?.name ??
                                  ParticipantProfile.student.name,
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontFamily: 'serif',
                                  color: AppColors.primary)),
                          const SizedBox(height: 8),
                          const Text(
                              'Atas partisipasinya sebagai peserta dalam kegiatan',
                              style: TextStyle(
                                  fontSize: 7, color: AppColors.muted),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 4),
                          Text(w.title,
                              style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 22),
                          const Text('PRATINJAU • BUKAN DOKUMEN RESMI',
                              style: TextStyle(
                                  fontSize: 6,
                                  letterSpacing: 1,
                                  color: AppColors.muted)),
                        ]))),
                if (!available)
                  Positioned.fill(
                      child: Container(
                          color: const Color(0xEEF8FAFC),
                          child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_outline,
                                    color: AppColors.muted, size: 28),
                                SizedBox(height: 8),
                                Text('Sertifikat belum tersedia',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.muted,
                                        fontWeight: FontWeight.w700))
                              ]))),
              ]),
              const SizedBox(height: 18),
              const InfoNote(
                  'Ini adalah pratinjau sertifikat contoh. Dokumen resmi dapat diunduh setelah diterbitkan oleh penyelenggara.',
                  icon: Icons.verified_outlined),
              const SizedBox(height: 12),
              AppButton('Unduh Sertifikat PDF',
                  icon: Icons.download_outlined,
                  onPressed: available
                      ? () => showDialog<void>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                                  title: const Text('Pratinjau Sertifikat',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800)),
                                  content: const Text(
                                      'Dokumen resmi belum diterbitkan untuk akun pratinjau ini.'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(dialogContext),
                                        child: const Text('Mengerti'))
                                  ]))
                      : null),
              const SizedBox(height: 12),
              if (available)
                AppButton(
                    corrected
                        ? 'Perbaikan Sedang Diperiksa'
                        : 'Ajukan Perbaikan Sertifikat',
                    secondary: true,
                    icon: Icons.edit_outlined,
                    onPressed: corrected
                        ? null
                        : () => context
                            .push('/certificates/$workshopId/correction')),
              if (corrected)
                const Padding(
                    padding: EdgeInsets.only(top: 14),
                    child: InfoNote(
                        'Pengajuan perbaikan diterima dalam pratinjau ini.')),
            ])));
  }
}

class CertificateCorrectionScreen extends ConsumerStatefulWidget {
  const CertificateCorrectionScreen({super.key, required this.workshopId});
  final String workshopId;
  @override
  ConsumerState<CertificateCorrectionScreen> createState() =>
      _CertificateCorrectionScreenState();
}

class _CertificateCorrectionScreenState
    extends ConsumerState<CertificateCorrectionScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(), _reason = TextEditingController();
  @override
  void initState() {
    super.initState();
    _name.text = ref.read(previewProvider).profile?.name ??
        ParticipantProfile.student.name;
  }

  @override
  void dispose() {
    _name.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Perbaikan Sertifikat')),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
              key: _form,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoNote(
                        findWorkshop(widget.workshopId)?.title ??
                            'Sertifikat tidak ditemukan',
                        icon: Icons.workspace_premium_outlined),
                    const SizedBox(height: 23),
                    const Text('Ajukan perbaikan data',
                        style: TextStyle(
                            fontSize: 23, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 7),
                    const Text(
                        'Tuliskan data yang benar dan alasan pengajuan Anda.',
                        style: TextStyle(color: AppColors.muted, fontSize: 13)),
                    const SizedBox(height: 26),
                    LabeledField(
                        label: 'Nama Lengkap yang Benar',
                        controller: _name,
                        validator: requiredValue),
                    const SizedBox(height: 16),
                    LabeledField(
                        label: 'Alasan Perbaikan',
                        controller: _reason,
                        hint: 'Jelaskan bagian yang perlu diperbaiki...',
                        maxLines: 5,
                        validator: requiredValue),
                    const SizedBox(height: 22),
                    AppButton('Kirim Pengajuan', onPressed: () {
                      if (!_form.currentState!.validate()) return;
                      ref
                          .read(previewProvider.notifier)
                          .requestCorrection(widget.workshopId);
                      context.pop();
                    }),
                  ]))));
}
