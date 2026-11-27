import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/participant_store.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/workshop_widgets.dart';

/// Verifikasi keaslian sertifikat secara publik berdasarkan nomornya
/// (GET /certificates/verify/:nomor) — sama dengan halaman verifikasi web.
class CertificateVerifyScreen extends ConsumerStatefulWidget {
  const CertificateVerifyScreen({super.key});

  @override
  ConsumerState<CertificateVerifyScreen> createState() =>
      _CertificateVerifyScreenState();
}

class _CertificateVerifyScreenState
    extends ConsumerState<CertificateVerifyScreen> {
  final _number = TextEditingController();
  bool _busy = false;
  String? _error;
  CertificateVerification? _result;

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final number = _number.text.trim();
    if (number.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await ref
          .read(participantStoreProvider.notifier)
          .verifyCertificate(number);
      if (mounted) setState(() => _result = result);
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Sertifikat')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const InfoNote(
            'Masukkan nomor sertifikat yang tertera pada dokumen untuk memeriksa keasliannya.',
            icon: Icons.verified_outlined),
        const SizedBox(height: 20),
        LabeledField(
            label: 'Nomor Sertifikat',
            controller: _number,
            hint: 'Contoh: UNAND/SERT/1004/2026',
            onSubmitted: (_) => _verify()),
        const SizedBox(height: 14),
        AppButton(_busy ? 'Memeriksa...' : 'Verifikasi',
            icon: Icons.search_rounded, onPressed: _busy ? null : _verify),
        if (_error != null) ...[
          const SizedBox(height: 18),
          InfoNote(_error!, warning: true, icon: Icons.gpp_bad_outlined),
        ],
        if (result != null) ...[
          const SizedBox(height: 18),
          SurfaceCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const StatusBadge('Sertifikat Sah'),
                const SizedBox(height: 14),
                DetailRow(
                    icon: Icons.person_outline,
                    label: 'Penerima',
                    value: result.recipient),
                const SizedBox(height: 14),
                DetailRow(
                    icon: Icons.event_outlined,
                    label: 'Kegiatan',
                    value: result.activity,
                    detail: result.activityDate),
                const SizedBox(height: 14),
                DetailRow(
                    icon: Icons.account_balance_outlined,
                    label: 'Penerbit',
                    value: result.issuer),
                const SizedBox(height: 14),
                DetailRow(
                    icon: Icons.tag_outlined,
                    label: 'Nomor',
                    value: result.number,
                    detail: 'Kode keaslian: ${result.authenticityCode}'),
                if (result.signers.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Text('Ditandatangani secara elektronik oleh',
                      style: TextStyle(fontSize: 11, color: AppColors.muted)),
                  const SizedBox(height: 6),
                  for (final signer in result.signers)
                    Text(signer, style: const TextStyle(fontSize: 11)),
                ],
              ])),
        ],
      ]),
    );
  }
}
