import 'package:flutter/material.dart';
import '../../../core/data/participant_models.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/workshop_widgets.dart';

class WorkshopVenueBadge extends StatelessWidget {
  const WorkshopVenueBadge(this.workshop, {super.key});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    final online = workshop.delivery == WorkshopDelivery.online;
    final color = online ? AppColors.blue : AppColors.statusGreen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: online ? AppColors.blueBg : AppColors.paleGreen,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(online ? Icons.videocam_outlined : Icons.location_on_outlined,
            size: 13, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(online ? 'Online' : workshop.location,
              style: TextStyle(
                  color: color,
                  fontSize: 10,
                  height: 1.4,
                  fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

class WorkshopImage extends StatelessWidget {
  const WorkshopImage(this.workshop, {super.key, this.height, this.width});
  final Workshop workshop;
  final double? height, width;

  Widget _placeholder() => Container(
      width: width,
      height: height,
      color: AppColors.paleGreen,
      child: const Icon(Icons.account_balance_outlined,
          color: AppColors.green, size: 36));

  @override
  Widget build(BuildContext context) {
    final src = workshop.image;
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return Image.network(src,
          width: width,
          height: height,
          fit: BoxFit.cover,
          cacheWidth: 900,
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : _placeholder(),
          errorBuilder: (_, __, ___) => _placeholder());
    }
    if (src.startsWith('assets/')) {
      return Image.asset(src,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder());
    }
    return _placeholder();
  }
}

class WorkshopCard extends StatelessWidget {
  const WorkshopCard(
      {super.key,
      required this.workshop,
      required this.onOpen,
      this.compact = false,
      this.registered = false});
  final Workshop workshop;
  final VoidCallback onOpen;
  final bool compact, registered;
  @override
  Widget build(BuildContext context) {
    final content = Padding(
        padding: EdgeInsets.all(compact ? 13 : 15),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ThemeTag(workshop.kind),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 5, children: [
                WorkshopVenueBadge(workshop),
                if (registered)
                  const StatusBadge('Terdaftar')
                else if (workshop.status != WorkshopStatus.open)
                  StatusBadge(workshop.registrationLabel,
                      tone: workshop.status == WorkshopStatus.waitlist
                          ? BadgeTone.amber
                          : BadgeTone.gray),
              ]),
              const SizedBox(height: 9),
              Text(workshop.title,
                  maxLines: compact ? 2 : null,
                  overflow: compact ? TextOverflow.ellipsis : null,
                  style: TextStyle(
                      fontSize: compact ? 14 : 15,
                      color: AppColors.heading,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      letterSpacing: -.2)),
              const SizedBox(height: 11),
              _meta(Icons.calendar_month_outlined, workshop.shortDate),
              const SizedBox(height: 6),
              _meta(Icons.schedule_outlined, workshop.time),
              if (workshop.delivery == WorkshopDelivery.online) ...[
                const SizedBox(height: 6),
                _meta(Icons.link_outlined, 'Tautan tersedia H-1',
                    color: AppColors.info),
              ],
              if (workshop.days.length > 1) ...[
                const SizedBox(height: 6),
                _meta(Icons.event_repeat_outlined,
                    '${workshop.days.length} hari • Presensi setiap hari'),
              ],
              if (!compact) ...[
                const SizedBox(height: 9),
                Text(workshop.organizer,
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.muted)),
                if (workshop.capacity != null &&
                    workshop.capacity! > 0 &&
                    workshop.status == WorkshopStatus.open) ...[
                  const SizedBox(height: 12),
                  Text('${workshop.remaining} kursi tersisa',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                          value: ((workshop.remaining ?? 0) /
                                  workshop.capacity!)
                              .clamp(0.0, 1.0),
                          minHeight: 4,
                          backgroundColor: AppColors.border,
                          color: AppColors.green)),
                ],
              ],
              const SizedBox(height: 14),
              AppButton('Lihat Detail', onPressed: onOpen, compact: true),
            ]));
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppTheme.radius),
            boxShadow: AppTheme.cardShadow),
        clipBehavior: Clip.antiAlias,
        child: compact
            ? IntrinsicHeight(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    WorkshopImage(workshop, width: 104),
                    Expanded(child: content)
                  ]))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [WorkshopImage(workshop, height: 154), content]));
  }

  Widget _meta(IconData icon, String text, {Color? color}) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 15, color: color ?? AppColors.green),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 11, height: 1.45, color: color ?? AppColors.muted)))
      ]);
}
