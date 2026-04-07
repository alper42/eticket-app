import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;

  const TicketCard({super.key, required this.ticket, required this.onTap});

  Color get _statusColor {
    switch (ticket.status) {
      case TicketStatus.active:  return AppTheme.success;
      case TicketStatus.used:    return AppTheme.textMuted;
      case TicketStatus.expired: return AppTheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.divider, width: 1),
          boxShadow: ticket.status == TicketStatus.active
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              _emoji(),
              const SizedBox(width: 16),
              Expanded(child: _info(context)),
              _price(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emoji() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(ticket.imageEmoji,
            style: const TextStyle(fontSize: 26)),
      ),
    );
  }

  Widget _info(BuildContext context) {
    final dateStr =
        '${ticket.eventDate.day.toString().padLeft(2, '0')}.'
        '${ticket.eventDate.month.toString().padLeft(2, '0')}.'
        '${ticket.eventDate.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ticket.eventName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          ticket.venue,
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _tag(dateStr, Icons.calendar_today_rounded),
            const SizedBox(width: 8),
            _statusDot(),
          ],
        ),
      ],
    );
  }

  Widget _tag(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppTheme.textMuted),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 12,
              color: AppTheme.textMuted,
            )),
      ],
    );
  }

  Widget _statusDot() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: _statusColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          ticket.status.label,
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 12,
            color: _statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _price() {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Text(
        '${ticket.price.toStringAsFixed(2)} €',
        style: const TextStyle(
          fontFamily: 'Outfit',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppTheme.accent,
        ),
      ),
    );
  }
}
