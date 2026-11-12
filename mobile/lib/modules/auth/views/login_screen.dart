import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/demo/preview_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/workshop_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _visible = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _signIn(ParticipantProfile profile) {
    ref.read(previewProvider.notifier).signIn(profile);
    context.go('/workshops');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Column(children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                24, MediaQuery.paddingOf(context).top + 30, 24, 42),
            decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(28))),
            child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UnandBrand(onDark: true),
                  SizedBox(height: 40),
                  StatusBadge('Workshop UNAND', onDark: true),
                  SizedBox(height: 13),
                  Text('Selamat Datang',
                      style: TextStyle(
                          fontSize: 37,
                          height: 1.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.5,
                          color: Colors.white)),
                  SizedBox(height: 8),
                  SizedBox(
                      width: 310,
                      child: Text(
                          'Masuk untuk menemukan dan mengikuti kegiatan Universitas Andalas.',
                          style: TextStyle(
                              fontSize: 14,
                              height: 1.55,
                              color: Color(0xFFD1FAE5)))),
                ]),
          ),
          Transform.translate(
              offset: const Offset(0, -18),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 26),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEEF0F2)),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x140F172A),
                          offset: Offset(0, 12),
                          blurRadius: 30)
                    ]),
                child: Column(children: [
                  const Row(children: [
                    _MethodIcon(),
                    SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Mahasiswa UNAND',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                          SizedBox(height: 3),
                          Text('Gunakan akun akademik kampus Anda.',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.muted)),
                        ])),
                  ]),
                  const SizedBox(height: 16),
                  AppButton('Masuk sebagai Mahasiswa',
                      onPressed: () => _signIn(ParticipantProfile.student)),
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 22),
                      child: Row(children: [
                        Expanded(child: Divider()),
                        Expanded(
                            flex: 4,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('atau masuk sebagai peserta umum',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 10, color: Color(0xFF94A3B8))),
                            )),
                        Expanded(child: Divider()),
                      ])),
                  Form(
                      key: _form,
                      child: Column(children: [
                        LabeledField(
                            label: 'Email',
                            controller: _email,
                            hint: 'nama@email.com',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: validateEmail),
                        const SizedBox(height: 16),
                        LabeledField(
                            label: 'Kata Sandi',
                            controller: _password,
                            hint: 'Minimal 6 karakter',
                            icon: Icons.lock_outline_rounded,
                            obscure: !_visible,
                            validator: validatePassword,
                            onSubmitted: (_) => _generalLogin(),
                            suffix: IconButton(
                                tooltip: _visible
                                    ? 'Sembunyikan kata sandi'
                                    : 'Tampilkan kata sandi',
                                onPressed: () =>
                                    setState(() => _visible = !_visible),
                                icon: Icon(
                                    _visible
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 18))),
                        const SizedBox(height: 16),
                        AppButton('Masuk', onPressed: _generalLogin),
                      ])),
                  const SizedBox(height: 22),
                  Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('Belum punya akun?',
                            style: TextStyle(
                                color: AppColors.muted, fontSize: 12)),
                        TextButton(
                            style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap),
                            onPressed: () => context.push('/register'),
                            child: const Text('Daftar sekarang')),
                      ]),
                ]),
              )),
          const SafeArea(
              top: false,
              child: Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text('Pratinjau antarmuka • data contoh',
                      style:
                          TextStyle(color: Color(0xFF94A3B8), fontSize: 10)))),
        ])),
      );

  void _generalLogin() {
    if (_form.currentState!.validate()) {
      _signIn(ParticipantProfile(
          name: 'Dinda Maharani',
          email: _email.text.trim(),
          phone: '0813 7788 9900',
          type: 'Peserta Umum'));
    }
  }
}

class _MethodIcon extends StatelessWidget {
  const _MethodIcon();
  @override
  Widget build(BuildContext context) => Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
          color: AppColors.paleGreen, borderRadius: BorderRadius.circular(11)),
      child: const Icon(Icons.verified_user_outlined,
          size: 21, color: AppColors.primary));
}
