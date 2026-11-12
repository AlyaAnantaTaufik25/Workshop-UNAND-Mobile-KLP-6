import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/demo/preview_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/workshop_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(previewProvider).profile ?? ParticipantProfile.student;
    return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 28),
            child: Column(children: [
              Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border:
                          Border.all(color: const Color(0xFFBBD9C3), width: 2)),
                  child: CircleAvatar(
                      radius: 35,
                      backgroundColor: AppColors.green,
                      child: Text(
                          p.name
                              .split(' ')
                              .where((s) => s.isNotEmpty)
                              .take(2)
                              .map((s) => s[0])
                              .join(),
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)))),
              const SizedBox(height: 12),
              Text(p.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              StatusBadge(p.type),
              const SizedBox(height: 28),
              SurfaceCard(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('Informasi Pribadi',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    DetailRow(
                        icon: Icons.person_outline,
                        label: 'Nama Lengkap',
                        value: p.name),
                    const SizedBox(height: 16),
                    DetailRow(
                        icon: Icons.mail_outline,
                        label: 'Email',
                        value: p.email),
                    const SizedBox(height: 16),
                    if (p.nim != null) ...[
                      DetailRow(
                          icon: Icons.badge_outlined,
                          label: 'Nomor Induk Mahasiswa',
                          value: p.nim!),
                      const SizedBox(height: 16)
                    ],
                    DetailRow(
                        icon: Icons.phone_outlined,
                        label: 'Nomor Telepon',
                        value: p.phone),
                  ])),
              const SizedBox(height: 16),
              AppButton('Edit Profil',
                  secondary: true,
                  icon: Icons.edit_outlined,
                  onPressed: () => context.push('/profile/edit')),
              const SizedBox(height: 10),
              SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.red,
                          side: const BorderSide(color: Color(0xFFFECACA))),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                                    title: const Text('Keluar dari akun?',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800)),
                                    content: const Text(
                                        'Anda perlu masuk kembali untuk mengakses kegiatan dan sertifikat.'),
                                    actions: [
                                      TextButton(
                                          onPressed: () => Navigator.pop(
                                              dialogContext, false),
                                          child: const Text('Batal')),
                                      TextButton(
                                          onPressed: () => Navigator.pop(
                                              dialogContext, true),
                                          child: const Text('Ya, Keluar',
                                              style: TextStyle(
                                                  color: AppColors.red)))
                                    ]));
                        if (confirmed == true && context.mounted) {
                          ref.read(previewProvider.notifier).signOut();
                          context.go('/login');
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Keluar'))),
              const SizedBox(height: 26),
              const Text('Workshop UNAND · Versi prototipe 1.0',
                  style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
              TextButton(
                  onPressed: () => context.push('/health'),
                  child: const Text('Cek koneksi server',
                      style: TextStyle(fontSize: 10))),
            ])));
  }
}

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final ParticipantProfile _profile;
  late final TextEditingController _name, _email, _phone;
  @override
  void initState() {
    super.initState();
    _profile = ref.read(previewProvider).profile ?? ParticipantProfile.student;
    _name = TextEditingController(text: _profile.name);
    _email = TextEditingController(text: _profile.email);
    _phone = TextEditingController(text: _profile.phone);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
              key: _form,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StatusBadge('Informasi Pribadi'),
                    const SizedBox(height: 12),
                    const Text('Perbarui data diri',
                        style: TextStyle(
                            fontSize: 23, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 7),
                    const Text('Pastikan informasi kontak Anda selalu sesuai.',
                        style: TextStyle(color: AppColors.muted, fontSize: 13)),
                    const SizedBox(height: 26),
                    LabeledField(
                        label: 'Nama Lengkap',
                        controller: _name,
                        validator: requiredValue),
                    const SizedBox(height: 16),
                    LabeledField(
                        label: 'Email', controller: _email, enabled: false),
                    const SizedBox(height: 16),
                    LabeledField(
                        label: 'Nomor Telepon',
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            (v?.replaceAll(RegExp(r'\D'), '').length ?? 0) < 10
                                ? 'Nomor telepon minimal 10 digit.'
                                : null),
                    const SizedBox(height: 22),
                    AppButton('Simpan Perubahan', onPressed: () {
                      if (!_form.currentState!.validate()) return;
                      ref.read(previewProvider.notifier).updateProfile(
                          ParticipantProfile(
                              name: _name.text.trim(),
                              email: _profile.email,
                              phone: _phone.text.trim(),
                              type: _profile.type,
                              nim: _profile.nim));
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Profil berhasil diperbarui.')));
                    }),
                    const SizedBox(height: 18),
                    const InfoNote(
                        'Perubahan pada pratinjau ini disimpan selama aplikasi terbuka.',
                        icon: Icons.shield_outlined),
                  ]))));
}
