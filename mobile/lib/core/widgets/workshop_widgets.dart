import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(
          'assets/images/unand-logo.png',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          semanticLabel: 'Logo Universitas Andalas',
        ),
      );
}

class UnandBrand extends StatelessWidget {
  const UnandBrand({super.key, this.compact = false, this.onDark = false});
  final bool compact, onDark;
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        UnandLogo(size: compact ? 44 : 56),
        const SizedBox(width: 11),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('UNAND',
              style: TextStyle(
                  color: onDark ? Colors.white : AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1)),
          if (!compact) ...[
            const SizedBox(height: 2),
            Text('Universitas Andalas',
                style: TextStyle(
                    color: onDark ? const Color(0xFFBBF7D0) : AppColors.muted,
                    fontSize: 10))
          ],
        ]),
      ]);
}

enum BadgeTone { green, amber, red, gray }

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.text,
      {super.key, this.tone = BadgeTone.green, this.onDark = false});
  final String text;
  final BadgeTone tone;
  final bool onDark;
  @override
  Widget build(BuildContext context) {
    final (foreground, background) = switch (tone) {
      BadgeTone.green => (const Color(0xFF166534), AppColors.paleGreen),
      BadgeTone.amber => (AppColors.amber, const Color(0xFFFEF3C7)),
      BadgeTone.red => (AppColors.red, const Color(0xFFFEE2E2)),
      BadgeTone.gray => (const Color(0xFF475569), const Color(0xFFF1F5F9)),
    };
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
            color: onDark ? Colors.white.withAlpha(31) : background,
            borderRadius: BorderRadius.circular(30)),
        child: Text(text,
            style: TextStyle(
                color: onDark ? const Color(0xFFDCFCE7) : foreground,
                fontSize: 10,
                height: 1.4,
                fontWeight: FontWeight.w700)));
  }
}

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
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Flexible(
              child: Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: compact ? 11 : 14,
                      fontWeight: FontWeight.w700))),
        ]);
    return SizedBox(
        width: double.infinity,
        child: secondary
            ? OutlinedButton(
                onPressed: onPressed,
                style: compact
                    ? OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 42),
                        padding: const EdgeInsets.all(9))
                    : null,
                child: content)
            : FilledButton(
                onPressed: onPressed,
                style: compact
                    ? FilledButton.styleFrom(
                        minimumSize: const Size(0, 42),
                        padding: const EdgeInsets.all(9))
                    : null,
                child: content));
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
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155))),
        const SizedBox(height: 7),
        TextFormField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            maxLines: maxLines,
            enabled: enabled,
            validator: validator,
            onFieldSubmitted: onSubmitted,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
                hintText: hint,
                prefixIcon: icon == null ? null : Icon(icon, size: 18),
                suffixIcon: suffix)),
      ]);
}

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
          borderRadius: BorderRadius.circular(13)),
      child: child);
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.caption});
  final String title;
  final String? caption;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(children: [
        Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.4))),
        if (caption != null)
          Text(caption!,
              style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
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
                borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 19, color: AppColors.primary)),
        const SizedBox(width: 11),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 9)),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 11,
                  height: 1.45,
                  fontWeight: FontWeight.w700)),
          if (detail != null)
            Text(detail!,
                style: const TextStyle(fontSize: 9, color: AppColors.muted)),
        ])),
      ]);
}

class InfoNote extends StatelessWidget {
  const InfoNote(this.text,
      {super.key, this.icon = Icons.info_outline, this.warning = false});
  final String text;
  final IconData icon;
  final bool warning;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
          color: warning ? const Color(0xFFFFFBEB) : AppColors.paleGreen,
          borderRadius: BorderRadius.circular(10)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon,
            size: 18, color: warning ? AppColors.amber : AppColors.primary),
        const SizedBox(width: 9),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 10,
                    height: 1.55,
                    color: warning
                        ? const Color(0xFF92400E)
                        : const Color(0xFF475569)))),
      ]));
}

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
        CircleAvatar(
            radius: 31,
            backgroundColor: AppColors.paleGreen,
            child: Icon(icon, size: 28, color: AppColors.primary)),
        const SizedBox(height: 15),
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center),
        const SizedBox(height: 7),
        Text(message,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
            textAlign: TextAlign.center),
        if (action != null) ...[
          const SizedBox(height: 18),
          ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 230), child: action)
        ],
      ]));
}

String? requiredValue(String? value) =>
    value == null || value.trim().isEmpty ? 'Bagian ini wajib diisi.' : null;
String? validateEmail(String? value) =>
    RegExp(r'^\S+@\S+\.\S+$').hasMatch(value?.trim() ?? '')
        ? null
        : 'Masukkan alamat email yang valid.';
String? validatePassword(String? value) =>
    (value?.length ?? 0) < 6 ? 'Kata sandi minimal 6 karakter.' : null;
