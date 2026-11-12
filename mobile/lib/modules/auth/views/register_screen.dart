import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/workshop_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String? _type;
  bool _success = false;
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _email = TextEditingController(),
      _phone = TextEditingController(),
      _password = TextEditingController(),
      _confirm = TextEditingController();
  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
              child: Center(
                  child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const CircleAvatar(
                            radius: 38,
                            backgroundColor: Color(0xFFDCFCE7),
                            child: Icon(Icons.check_rounded,
                                size: 36, color: AppColors.green)),
                        const SizedBox(height: 25),
                        const StatusBadge('Akun berhasil dibuat'),
                        const SizedBox(height: 13),
                        const Text('Registrasi Berhasil!',
                            style: TextStyle(
                                fontSize: 27, fontWeight: FontWeight.w800),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 9),
                        const Text(
                            'Simulasi pendaftaran selesai. Silakan kembali untuk mencoba tampilan masuk.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.muted, fontSize: 13)),
                        const SizedBox(height: 28),
                        AppButton('Kembali ke Login',
                            onPressed: () => context.go('/login')),
                      ])))));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
          child: SafeArea(
              top: false,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StatusBadge('Workshop UNAND'),
                    const SizedBox(height: 12),
                    const Text('Pilih jenis peserta',
                        style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.7)),
                    const SizedBox(height: 7),
                    const Text(
                        'Pilih cara pendaftaran yang sesuai dengan status Anda.',
                        style: TextStyle(fontSize: 13, color: AppColors.muted)),
                    const SizedBox(height: 26),
                    _typeCard('student', 'Mahasiswa UNAND',
                        'Gunakan akun akademik kampus', Icons.school_outlined),
                    const SizedBox(height: 11),
                    _typeCard(
                        'general',
                        'Peserta Umum',
                        'Buat akun menggunakan email pribadi',
                        Icons.groups_outlined),
                    const SizedBox(height: 20),
                    if (_type == null)
                      const InfoNote(
                          'Pilih salah satu jenis peserta untuk melanjutkan pendaftaran akun.'),
                    if (_type == 'student') ...[
                      const InfoNote(
                          'Data identitas mahasiswa akan diambil dari akun akademik UNAND dan tidak perlu diisi ulang.',
                          icon: Icons.school_outlined),
                      const SizedBox(height: 16),
                      AppButton('Lanjutkan dengan Akun UNAND',
                          onPressed: () => setState(() => _success = true)),
                    ],
                    if (_type == 'general')
                      Form(
                          key: _form,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Formulir Peserta Umum',
                                    style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11)),
                                const SizedBox(height: 16),
                                LabeledField(
                                    label: 'Nama Lengkap',
                                    controller: _name,
                                    hint: 'Sesuai identitas resmi',
                                    validator: requiredValue),
                                const SizedBox(height: 16),
                                LabeledField(
                                    label: 'Email',
                                    controller: _email,
                                    hint: 'nama@email.com',
                                    keyboardType: TextInputType.emailAddress,
                                    validator: validateEmail),
                                const SizedBox(height: 16),
                                LabeledField(
                                    label: 'Nomor Telepon',
                                    controller: _phone,
                                    hint: '08xx xxxx xxxx',
                                    keyboardType: TextInputType.phone,
                                    validator: (v) => (v
                                                    ?.replaceAll(
                                                        RegExp(r'\D'), '')
                                                    .length ??
                                                0) <
                                            10
                                        ? 'Nomor telepon minimal 10 digit.'
                                        : null),
                                const SizedBox(height: 16),
                                LabeledField(
                                    label: 'Kata Sandi',
                                    controller: _password,
                                    hint: 'Minimal 6 karakter',
                                    obscure: true,
                                    validator: validatePassword),
                                const SizedBox(height: 16),
                                LabeledField(
                                    label: 'Konfirmasi Kata Sandi',
                                    controller: _confirm,
                                    hint: 'Ulangi kata sandi',
                                    obscure: true,
                                    validator: (v) => v != _password.text
                                        ? 'Konfirmasi kata sandi tidak sesuai.'
                                        : requiredValue(v)),
                                const SizedBox(height: 16),
                                AppButton('Daftar Akun', onPressed: () {
                                  if (_form.currentState!.validate()) {
                                    setState(() => _success = true);
                                  }
                                }),
                              ])),
                    const SizedBox(height: 18),
                    const InfoNote(
                        'Data Anda hanya digunakan untuk keperluan layanan kegiatan Universitas Andalas.',
                        icon: Icons.shield_outlined),
                  ]))),
    );
  }

  Widget _typeCard(String type, String title, String subtitle, IconData icon) {
    final active = _type == type;
    return Semantics(
        selected: active,
        child: Material(
            color: active ? AppColors.paleGreen : Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                    color: active ? AppColors.green : AppColors.border)),
            child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _type = type),
                child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color: active
                                  ? AppColors.primary
                                  : AppColors.paleGreen,
                              borderRadius: BorderRadius.circular(10)),
                          child: Icon(icon,
                              color: active ? Colors.white : AppColors.primary,
                              size: 23)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(title,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(subtitle,
                                style: const TextStyle(
                                    color: AppColors.muted, fontSize: 9))
                          ])),
                      Icon(
                          active
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: active
                              ? AppColors.green
                              : const Color(0xFFCBD5E1),
                          size: 21),
                    ])))));
  }
}
