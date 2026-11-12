import 'package:flutter/material.dart';
import '../../../core/demo/preview_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/workshop_widgets.dart';

class WorkshopVenueBadge extends StatelessWidget {
  const WorkshopVenueBadge(this.workshop, {super.key});
  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    final online = workshop.delivery == WorkshopDelivery.online;
    final color = online ? const Color(0xFF1D4ED8) : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: online ? const Color(0xFFEFF6FF) : AppColors.paleGreen,
        borderRadius: BorderRadius.circular(30),
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
  @override
  Widget build(BuildContext context) => Image.asset(workshop.image,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: AppColors.paleGreen,
          child: const Icon(Icons.account_balance_outlined,
              color: AppColors.green, size: 36)));
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
              Wrap(spacing: 8, runSpacing: 5, children: [
                StatusBadge(workshop.kind),
                WorkshopVenueBadge(workshop),
                if (registered)
                  const StatusBadge('Terdaftar', tone: BadgeTone.gray)
              ]),
              const SizedBox(height: 9),
              Text(workshop.title,
                  maxLines: compact ? 2 : null,
                  overflow: compact ? TextOverflow.ellipsis : null,
                  style: TextStyle(
                      fontSize: compact ? 13 : 15,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      letterSpacing: -.2)),
              const SizedBox(height: 11),
              _meta(Icons.calendar_month_outlined, workshop.shortDate),
              if (workshop.delivery == WorkshopDelivery.online) ...[
                const SizedBox(height: 6),
                _meta(Icons.videocam_outlined, workshop.location),
              ],
              if (!compact) ...[
                const SizedBox(height: 9),
                Text(workshop.organizer,
                    style:
                        const TextStyle(fontSize: 10, color: AppColors.muted)),
                if (workshop.capacity != null &&
                    workshop.status == WorkshopStatus.open) ...[
                  const SizedBox(height: 12),
                  Text('${workshop.remaining} kursi tersisa',
                      style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                          value: (workshop.remaining ?? 0) / workshop.capacity!,
                          minHeight: 4,
                          backgroundColor: AppColors.border,
                          color: AppColors.green)),
                ],
              ],
              const SizedBox(height: 14),
              AppButton('Lihat Detail',
                  onPressed: onOpen, secondary: true, compact: true),
            ]));
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE8EBEE)),
            borderRadius: BorderRadius.circular(13),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0A0F172A),
                  offset: Offset(0, 4),
                  blurRadius: 14)
            ]),
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
                children: [WorkshopImage(workshop, height: 150), content]));
  }

  Widget _meta(IconData icon, String text) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 15, color: AppColors.green),
        const SizedBox(width: 6),
        Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 10, color: AppColors.muted)))
      ]);
}
