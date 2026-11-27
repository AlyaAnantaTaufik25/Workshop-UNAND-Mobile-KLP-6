import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/participant_store.dart';
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
  bool _busy = false;
  bool _restoring = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Pulihkan sesi tersimpan; router berpindah otomatis bila masih berlaku
    Future.microtask(() async {
      try {
        await ref.read(participantStoreProvider.notifier).restoreSession();
      } catch (e) {
        if (mounted) setState(() => _error = errorMessage(e));
      } finally {
        if (mounted) setState(() => _restoring = false);
      }
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(participantStoreProvider.notifier)
          .signIn(_email.text, _password.text);
      if (mounted) context.go('/workshops');
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
            // Panel kiri halaman login web (.login-left, --green-900)
            color: const Color(0xFF1B4332),
            child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UnandBrand(onDark: true),
                  SizedBox(height: 40),
                  StatusBadge('Workshop UNAND', onDark: true),
                  SizedBox(height: 13),
                  Text('Selamat Datang',
                      style: TextStyle(
                          fontSize: 30,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -.5,
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
                    borderRadius: BorderRadius.circular(8),
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
                          Text('Masuk Peserta',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                          SizedBox(height: 3),
                          Text(
                              'Mahasiswa UNAND dan peserta umum memakai email & kata sandi akun Workshop UNAND.',
                              style: TextStyle(
                                  fontSize: 11, color: AppColors.muted)),
                        ])),
                  ]),
                  const SizedBox(height: 20),
                  if (_restoring)
                    const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: LinearProgressIndicator(minHeight: 2)),
                  if (_error != null) ...[
                    InfoNote(_error!, warning: true),
                    const SizedBox(height: 16),
                  ],
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
                            hint: 'Kata sandi akun Anda',
                            icon: Icons.lock_outline_rounded,
                            obscure: !_visible,
                            validator: requiredValue,
                            onSubmitted: (_) => _signIn(),
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
                        AppButton(_busy ? 'Memproses...' : 'Masuk',
                            onPressed: _busy || _restoring ? null : _signIn),
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
                            onPressed: () => context.go('/register'),
                            child: const Text('Daftar sekarang')),
                      ]),
                ]),
              )),
          const SafeArea(
              top: false,
              child: Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text('Terhubung ke layanan Workshop UNAND',
                      style:
                          TextStyle(color: Color(0xFF94A3B8), fontSize: 11)))),
        ])),
      );
}

class _MethodIcon extends StatelessWidget {
  const _MethodIcon();
  @override
  Widget build(BuildContext context) => Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
          color: AppColors.paleGreen, borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.verified_user_outlined,
          size: 21, color: AppColors.primary));
}
