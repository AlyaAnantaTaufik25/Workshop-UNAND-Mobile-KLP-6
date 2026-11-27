import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../network/api_exceptions.dart';

/// Komponen UI peserta yang disamakan dengan portal web
/// (kelas `.peserta-*` dan `.dash-*` pada frontend web).

class UnandLogo extends StatelessWidget {
  const UnandLogo({super.key, this.size = 56});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radius),
        ),
        child: Image.asset(
          'assets/images/unand-logo.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          semanticLabel: 'Logo Universitas Andalas',
        ),
      );
}

/// Merek seperti sidebar web: logo + "Workshop UNAND" + "Portal Peserta"
class UnandBrand extends StatelessWidget {
  const UnandBrand({super.key, this.compact = false, this.onDark = false});
  final bool compact, onDark;
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        UnandLogo(size: compact ? 38 : 48),
        const SizedBox(width: 11),
        Flexible(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Workshop UNAND',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: onDark ? Colors.white : AppColors.primary,
                  fontSize: compact ? 13 : 15,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text('Portal Peserta',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: onDark ? const Color(0xFFBBF7D0) : AppColors.muted,
                  fontSize: 10))
        ])),
      ]);
}

/// Judul halaman gaya topbar web: eyebrow "WORKSHOP UNAND" + judul
class PageTitle extends StatelessWidget {
  const PageTitle(this.title, {super.key});
  final String title;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('WORKSHOP UNAND',
            style: TextStyle(
                color: AppColors.green,
                fontSize: 9,
                letterSpacing: .4,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(title,
            style: const TextStyle(
                color: AppColors.heading,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
      ]);
}

enum BadgeTone { green, amber, red, gray, blue }

/// `.peserta-status`: pil dengan titik warna
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.text,
      {super.key, this.tone = BadgeTone.green, this.onDark = false});
  final String text;
  final BadgeTone tone;
  final bool onDark;
  @override
  Widget build(BuildContext context) {
    final (foreground, background) = switch (tone) {
      BadgeTone.green => (AppColors.statusGreen, AppColors.paleGreen),
      BadgeTone.amber => (AppColors.amber, AppColors.amberBg),
      BadgeTone.red => (AppColors.red, AppColors.redBg),
      BadgeTone.gray => (AppColors.gray, AppColors.grayBg),
      BadgeTone.blue => (AppColors.blue, AppColors.blueBg),
    };
    final color = onDark ? const Color(0xFFDCFCE7) : foreground;
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: onDark ? Colors.white.withAlpha(31) : background,
            borderRadius: BorderRadius.circular(99)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Flexible(
              child: Text(text,
                  style: TextStyle(
                      color: color,
                      fontSize: 10,
                      height: 1.4,
                      fontWeight: FontWeight.w700))),
        ]));
  }
}

/// `.peserta-card-theme`: label tema kegiatan, huruf kapital hijau
class ThemeTag extends StatelessWidget {
  const ThemeTag(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
          color: AppColors.green,
          fontSize: 10,
          letterSpacing: .3,
          fontWeight: FontWeight.w700));
}

/// `.peserta-button` (utama, dengan bayangan) dan `--secondary` (garis)
class AppButton extends StatelessWidget {
  const AppButton(this.label,
      {super.key,
      required this.onPressed,
      this.secondary = false,
      this.icon,
      this.compact = false});
  final String label;
  final VoidCallback? onPressed;
  final bool secondary, compact;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    final content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 16 : 18),
            const SizedBox(width: 8)
          ],
          Flexible(
              child: Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: compact ? 12 : 13,
                      fontWeight: FontWeight.w700))),
        ]);
    final compactSize = compact
        ? const Size(0, 40)
        : const Size(0, 46);
    final button = secondary
        ? OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
                minimumSize: compactSize,
                padding: EdgeInsets.symmetric(
                    horizontal: compact ? 10 : 15, vertical: 9)),
            child: content)
        : FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
                minimumSize: compactSize,
                padding: EdgeInsets.symmetric(
                    horizontal: compact ? 10 : 15, vertical: 9)),
            child: content);
    return SizedBox(
        width: double.infinity,
        child: secondary || onPressed == null
            ? button
            : DecoratedBox(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                    boxShadow: AppTheme.buttonShadow),
                child: button));
  }
}

class LabeledField extends StatelessWidget {
  const LabeledField(
      {super.key,
      required this.label,
      required this.controller,
      this.hint,
      this.icon,
      this.obscure = false,
      this.suffix,
      this.validator,
      this.keyboardType,
      this.maxLines = 1,
      this.enabled = true,
      this.onSubmitted});
  final String label;
  final TextEditingController controller;
  final String? hint;
  final IconData? icon;
  final bool obscure, enabled;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onSubmitted;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.text)),
        const SizedBox(height: 7),
        TextFormField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            maxLines: maxLines,
            enabled: enabled,
            validator: validator,
            onFieldSubmitted: onSubmitted,
            style: const TextStyle(fontSize: 13, color: AppColors.text),
            decoration: InputDecoration(
                hintText: hint,
                prefixIcon: icon == null ? null : Icon(icon, size: 18),
                suffixIcon: suffix)),
      ]);
}

/// Kartu putih bergaris tipis dengan bayangan lembut (`.peserta-workshop-card`)
class SurfaceCard extends StatelessWidget {
  const SurfaceCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(17)});
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Container(
      padding: padding,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppTheme.radius),
          boxShadow: AppTheme.cardShadow),
      child: child);
}

/// `.peserta-section-line`: judul bagian + keterangan redup
class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.caption});
  final String title;
  final String? caption;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.heading,
                    fontWeight: FontWeight.w700))),
        if (caption != null)
          Text(caption!,
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
      ]));
}

class DetailRow extends StatelessWidget {
  const DetailRow(
      {super.key,
      required this.icon,
      required this.label,
      required this.value,
      this.detail});
  final IconData icon;
  final String label, value;
  final String? detail;
  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: AppColors.paleGreen,
                borderRadius: BorderRadius.circular(AppTheme.radius)),
            child: Icon(icon, size: 18, color: AppColors.primary)),
        const SizedBox(width: 11),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                  height: 1.45,
                  fontWeight: FontWeight.w600)),
          if (detail != null)
            Text(detail!,
                style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        ])),
      ]);
}

/// Kotak keterangan: biru seperti `.peserta-info`, amber bila [warning]
class InfoNote extends StatelessWidget {
  const InfoNote(this.text,
      {super.key, this.icon = Icons.info_outline, this.warning = false});
  final String text;
  final IconData icon;
  final bool warning;
  @override
  Widget build(BuildContext context) {
    final foreground = warning ? AppColors.amber : AppColors.info;
    return Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
            color: warning ? AppColors.amberBg : AppColors.infoBg,
            borderRadius: BorderRadius.circular(6)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 12, height: 1.55, color: foreground))),
        ]));
  }
}

/// `.peserta-empty`: ikon bulat tint, judul, keterangan, aksi
class AppEmptyState extends StatelessWidget {
  const AppEmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.message,
      this.action});
  final IconData icon;
  final String title, message;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 48),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
                color: AppColors.paleGreen, shape: BoxShape.circle),
            child: Icon(icon, size: 30, color: AppColors.primary)),
        const SizedBox(height: 14),
        Text(title,
            style: const TextStyle(
                fontSize: 17,
                color: AppColors.heading,
                fontWeight: FontWeight.w700),
            textAlign: TextAlign.center),
        const SizedBox(height: 6),
        ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Text(message,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
                textAlign: TextAlign.center)),
        if (action != null) ...[
          const SizedBox(height: 18),
          ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 230), child: action)
        ],
      ]));
}

/// `.dash-stat`: kartu statistik ringkas (ikon tint + label + angka)
class StatTile extends StatelessWidget {
  const StatTile(
      {super.key,
      required this.icon,
      required this.label,
      required this.value,
      this.onTap});
  final IconData icon;
  final String label;
  final int value;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                        color: AppColors.paleGreen,
                        borderRadius: BorderRadius.circular(11)),
                    child: Icon(icon, size: 19, color: AppColors.primary)),
                const SizedBox(width: 11),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('$value',
                          style: const TextStyle(
                              fontSize: 22,
                              height: 1.1,
                              fontWeight: FontWeight.w800,
                              color: AppColors.heading)),
                      const SizedBox(height: 2),
                      Text(label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.muted)),
                    ])),
              ]))));
}

/// `.peserta-datebox`: kotak tanggal (angka tanggal + bulan singkat)
class DateBox extends StatelessWidget {
  const DateBox({super.key, required this.day, required this.month, this.muted = false});
  final String day, month;
  final bool muted;
  @override
  Widget build(BuildContext context) {
    final color = muted ? AppColors.muted : AppColors.primary;
    return Container(
        width: 58,
        constraints: const BoxConstraints(minHeight: 65),
        decoration: BoxDecoration(
            color: muted ? AppColors.grayBg : AppColors.paleGreen,
            borderRadius: BorderRadius.circular(AppTheme.radius)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(day,
              style: TextStyle(
                  fontSize: 22,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: color)),
          Text(month.toUpperCase(),
              style: TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w700, color: color)),
        ]));
  }
}

String? requiredValue(String? value) =>
    value == null || value.trim().isEmpty ? 'Bagian ini wajib diisi.' : null;
String? validateEmail(String? value) =>
    RegExp(r'^\S+@\S+\.\S+$').hasMatch(value?.trim() ?? '')
        ? null
        : 'Masukkan alamat email yang valid.';

/// Sama dengan aturan backend (auth.validation.js): minimal 8 karakter
String? validatePassword(String? value) =>
    (value?.length ?? 0) < 8 ? 'Kata sandi minimal 8 karakter.' : null;

/// Pesan galat yang ramah untuk ditampilkan ke peserta
String errorMessage(Object error) {
  if (error is ApiException) return error.message;
  if (error is UnsupportedError) return error.message ?? 'Fitur belum didukung.';
  return 'Terjadi kesalahan. Silakan coba lagi.';
}

/// Menampilkan pesan singkat di bagian bawah layar
void showMessage(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.red : null));
}

/// Banner galat dengan tombol coba lagi (mis. gagal memuat data)
class LoadErrorBanner extends StatelessWidget {
  const LoadErrorBanner(this.message, {super.key, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        InfoNote(message, warning: true, icon: Icons.cloud_off_outlined),
        const SizedBox(height: 8),
        AppButton('Coba Lagi',
            secondary: true, compact: true, onPressed: onRetry),
      ]));
}
