import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/participant_store.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/workshop_widgets.dart';

class CertificateListScreen extends ConsumerWidget {
  const CertificateListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(participantStoreProvider);
    final store = ref.read(participantStoreProvider.notifier);
    final available = state.certificates;
    // Kegiatan yang diikuti namun sertifikatnya belum terbit
    final waiting = state.registrations.values
        .where((r) =>
            !r.isWaiting &&
            r.workshop.phase != WorkshopPhase.upcoming &&
            !r.workshop.cancelled &&
            state.certificateFor(r.workshopId) == null)
        .toList();
    return Scaffold(
        appBar: AppBar(title: const PageTitle('Sertifikat'), actions: [
          IconButton(
              tooltip: 'Verifikasi sertifikat',
              onPressed: () => context.push('/certificates/verify'),
              icon: const Icon(Icons.verified_outlined))
        ]),
        body: RefreshIndicator(
            onRefresh: store.refresh,
            child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  if (state.error != null)
                    LoadErrorBanner(state.error!, onRetry: store.refresh),
                  const InfoNote(
                      'Sertifikat tersedia setelah kehadiran Anda sah dan proses penerbitan selesai.',
                      icon: Icons.workspace_premium_outlined),
                  if (state.loading && !state.loaded)
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator())),
                  const SizedBox(height: 27),
                  SectionHeading('Sertifikat Tersedia',
                      caption: '${available.length}'),
                  if (available.isEmpty)
                    const Text('Belum ada sertifikat yang terbit.',
                        style: TextStyle(fontSize: 11, color: AppColors.muted)),
                  for (final certificate in available) ...[
                    _card(
                        context,
                        workshopId: certificate.workshopId,
                        kind: certificate.kind,
                        title: state.workshopById(certificate.workshopId)?.title ??
                            certificate.number,
                        date: state
                                .workshopById(certificate.workshopId)
                                ?.shortDate ??
                            'Terbit ${certificate.issued}',
                        available: true),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 15),
                  SectionHeading('Belum Tersedia', caption: '${waiting.length}'),
                  if (waiting.isEmpty)
                    const Text('Tidak ada sertifikat yang sedang diproses.',
                        style: TextStyle(fontSize: 11, color: AppColors.muted)),
                  for (final registration in waiting) ...[
                    _card(context,
                        workshopId: registration.workshopId,
                        kind: registration.workshop.kind,
                        title: registration.workshop.title,
                        date: registration.workshop.shortDate,
                        available: false),
                    const SizedBox(height: 12),
                  ],
                ])));
  }

  Widget _card(BuildContext context,
          {required String workshopId,
          required String kind,
          required String title,
          required String date,
          required bool available}) =>
      SurfaceCard(
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                    color: AppColors.paleGreen,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.workspace_premium_outlined,
                    color: AppColors.primary, size: 24)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Wrap(spacing: 8, runSpacing: 5, children: [
                    StatusBadge(kind),
                    StatusBadge(available ? 'Tersedia' : 'Belum Tersedia',
                        tone: available ? BadgeTone.green : BadgeTone.amber)
                  ]),
                  const SizedBox(height: 8),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 7),
                  Text(date,
                      style:
                          const TextStyle(fontSize: 11, color: AppColors.muted)),
                  if (!available) ...[
                    const SizedBox(height: 7),
                    const Text('Menunggu validasi kehadiran dan penerbitan.',
                        style: TextStyle(fontSize: 11, color: AppColors.amber))
                  ],
                  const SizedBox(height: 11),
                  AppButton('Lihat Detail',
                      secondary: true,
                      compact: true,
                      onPressed: () =>
                          context.push('/certificates/$workshopId')),
                ])),
          ]));
}

class CertificateDetailScreen extends ConsumerStatefulWidget {
  const CertificateDetailScreen({super.key, required this.workshopId});
  final String workshopId;
  @override
  ConsumerState<CertificateDetailScreen> createState() =>
      _CertificateDetailScreenState();
}

class _CertificateDetailScreenState
    extends ConsumerState<CertificateDetailScreen> {
  bool _downloading = false;

  Future<void> _download(Certificate certificate) async {
    setState(() => _downloading = true);
    try {
      await ref
          .read(participantStoreProvider.notifier)
          .downloadCertificate(certificate);
      if (mounted) showMessage(context, 'Sertifikat berhasil diunduh.');
    } catch (e) {
      if (mounted) showMessage(context, errorMessage(e), error: true);
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(participantStoreProvider);
    final w = state.workshopById(widget.workshopId);
    final certificate = state.certificateFor(widget.workshopId);
    final registration = state.registrationFor(widget.workshopId);
    final available = certificate != null;
    final correction =
        certificate == null ? null : state.correctionFor(certificate.code);
    if (w == null && certificate == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Detail Sertifikat')),
          body: state.loading
              ? const Center(child: CircularProgressIndicator())
              : const AppEmptyState(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Sertifikat tidak ditemukan',
                  message: 'Silakan kembali ke daftar sertifikat.'));
    }
    final title = w?.title ?? certificate!.number;
    final recipient =
        certificate?.recipient ?? state.profile?.name ?? 'Peserta';
    final issuer = certificate?.issuer ?? 'UNAND';
    return Scaffold(
        appBar: AppBar(title: const Text('Detail Sertifikat')),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              StatusBadge(available ? 'Tersedia' : 'Belum Tersedia',
                  tone: available ? BadgeTone.green : BadgeTone.amber),
              const SizedBox(height: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      letterSpacing: -.5)),
              const SizedBox(height: 6),
              Text(w?.shortDate ?? 'Terbit ${certificate?.issued ?? '-'}',
                  style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              const SizedBox(height: 20),
              Stack(children: [
                Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                            Border.all(color: AppColors.primary, width: 2.5)),
                    child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.primary, width: 1.2)),
                        child: Column(children: [
                          const UnandLogo(size: 48),
                          const SizedBox(height: 6),
                          Text(
                              issuer == 'UNAND'
                                  ? 'UNIVERSITAS ANDALAS'
                                  : issuer.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 8,
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
                                  fontSize: 8, color: AppColors.muted)),
                          const SizedBox(height: 4),
                          Text(
                              certificate != null && certificate.degree.isNotEmpty
                                  ? '$recipient, ${certificate.degree}'
                                  : recipient,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontFamily: 'serif',
                                  color: AppColors.primary)),
                          const SizedBox(height: 8),
                          const Text(
                              'Atas partisipasinya sebagai peserta dalam kegiatan',
                              style: TextStyle(
                                  fontSize: 8, color: AppColors.muted),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 4),
                          Text(title,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 22),
                          Text(
                              certificate != null
                                  ? 'No. ${certificate.number}'
                                  : 'BELUM DITERBITKAN',
                              style: const TextStyle(
                                  fontSize: 8,
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
                                        fontSize: 11,
                                        color: AppColors.muted,
                                        fontWeight: FontWeight.w700))
                              ]))),
              ]),
              const SizedBox(height: 18),
              InfoNote(
                  available
                      ? 'Dokumen resmi berformat PDF dilengkapi QR verifikasi keaslian.'
                      : registration == null
                          ? 'Anda tidak terdaftar pada kegiatan ini.'
                          : 'Sertifikat terbit setelah kehadiran Anda sah dan penandatanganan selesai.',
                  icon: Icons.verified_outlined),
              const SizedBox(height: 12),
              AppButton(
                  _downloading ? 'Mengunduh...' : 'Unduh Sertifikat PDF',
                  icon: Icons.download_outlined,
                  onPressed: certificate == null || _downloading
                      ? null
                      : () => _download(certificate)),
              const SizedBox(height: 12),
              if (certificate != null)
                AppButton(
                    correction?.isActive ?? false
                        ? 'Perbaikan Sedang Diperiksa'
                        : 'Ajukan Perbaikan Sertifikat',
                    secondary: true,
                    icon: Icons.edit_outlined,
                    onPressed: correction?.isActive ?? false
                        ? null
                        : () => context.push(
                            '/certificates/${widget.workshopId}/correction')),
              if (correction != null)
                Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: InfoNote(
                        'Pengajuan ${correction.id}: ${correction.statusLabel}'
                        '${correction.issuerNote != null ? '. ${correction.issuerNote}' : ''}'
                        '${correction.replacementNumber != null ? ' Nomor pengganti: ${correction.replacementNumber}.' : ''}',
                        warning: correction.status == 'ditolak')),
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
  final _name = TextEditingController(),
      _degree = TextEditingController(),
      _reason = TextEditingController();
  bool _agreed = false;
  bool _busy = false;
  String? _error;
  Certificate? _certificate;

  @override
  void initState() {
    super.initState();
    _certificate =
        ref.read(participantStoreProvider).certificateFor(widget.workshopId);
    _name.text = _certificate?.recipient ?? '';
    _degree.text = _certificate?.degree ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _degree.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final certificate = _certificate;
    if (certificate == null || _busy || !_form.currentState!.validate()) {
      return;
    }
    final changes = <String, String>{
      if (_name.text.trim() != certificate.recipient) 'recipient': _name.text.trim(),
      if (_degree.text.trim().isNotEmpty &&
          _degree.text.trim() != certificate.degree)
        'degree': _degree.text.trim(),
    };
    if (changes.isEmpty) {
      setState(() => _error = 'Ubah minimal satu data yang perlu diperbaiki.');
      return;
    }
    if (!_agreed) {
      setState(() =>
          _error = 'Setujui pernyataan kebenaran data sebelum mengirim.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(participantStoreProvider.notifier).requestCorrection(
          certificate,
          changes: changes,
          reason: _reason.text.trim());
      if (!mounted) return;
      context.pop();
      showMessage(context, 'Pengajuan perbaikan terkirim ke penerbit.');
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = ref.watch(participantStoreProvider).workshopById(widget.workshopId);
    if (_certificate == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Perbaikan Sertifikat')),
          body: const AppEmptyState(
              icon: Icons.workspace_premium_outlined,
              title: 'Sertifikat tidak ditemukan',
              message: 'Perbaikan hanya untuk sertifikat yang sudah terbit.'));
    }
    return Scaffold(
        appBar: AppBar(title: const Text('Perbaikan Sertifikat')),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
                key: _form,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoNote(
                          '${w?.title ?? 'Sertifikat'} · No. ${_certificate!.number}',
                          icon: Icons.workspace_premium_outlined),
                      const SizedBox(height: 23),
                      const Text('Ajukan perbaikan data',
                          style: TextStyle(
                              fontSize: 23, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 7),
                      const Text(
                          'Tuliskan data yang benar dan alasan pengajuan Anda.',
                          style:
                              TextStyle(color: AppColors.muted, fontSize: 13)),
                      const SizedBox(height: 26),
                      LabeledField(
                          label: 'Nama Lengkap yang Benar',
                          controller: _name,
                          validator: requiredValue),
                      const SizedBox(height: 16),
                      LabeledField(
                          label: 'Gelar (opsional)',
                          controller: _degree,
                          hint: 'Contoh: S.Kom.'),
                      const SizedBox(height: 16),
                      LabeledField(
                          label: 'Alasan Perbaikan',
                          controller: _reason,
                          hint: 'Jelaskan bagian yang perlu diperbaiki...',
                          maxLines: 5,
                          validator: (v) {
                            final length = v?.trim().length ?? 0;
                            if (length < 10) {
                              return 'Alasan minimal 10 karakter.';
                            }
                            return length > 1000
                                ? 'Alasan maksimal 1.000 karakter.'
                                : null;
                          }),
                      const SizedBox(height: 10),
                      CheckboxListTile(
                          value: _agreed,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (value) =>
                              setState(() => _agreed = value ?? false),
                          title: const Text(
                              'Saya menyatakan data yang saya ajukan benar dan dapat dipertanggungjawabkan.',
                              style: TextStyle(fontSize: 11))),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        InfoNote(_error!, warning: true),
                      ],
                      const SizedBox(height: 16),
                      AppButton(_busy ? 'Mengirim...' : 'Kirim Pengajuan',
                          onPressed: _busy ? null : _submit),
                    ]))));
  }
}
