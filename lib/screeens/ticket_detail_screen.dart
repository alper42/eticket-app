import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';
import '../theme/app_theme.dart';
import '../widgets/qr_widget.dart';

class TicketDetailScreen extends StatefulWidget {
  final Ticket ticket;
  const TicketDetailScreen({super.key, required this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen>
    with TickerProviderStateMixin {
  late Ticket _ticket;
  late AnimationController _glowCtrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 8, end: 22).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  Future<void> _markUsed() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ticket einlösen?',
            style: TextStyle(fontFamily: 'Outfit', color: AppTheme.textPrimary)),
        content: const Text(
          'Das Ticket wird als verwendet markiert und kann danach nicht mehr genutzt werden.',
          style: TextStyle(fontFamily: 'Outfit', color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Einlösen',
                style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await TicketService.instance.markAsUsed(_ticket.id);
      HapticFeedback.mediumImpact();
      if (mounted) Navigator.pop(context, true);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ticket löschen?',
            style: TextStyle(fontFamily: 'Outfit', color: AppTheme.textPrimary)),
        content: const Text(
          'Das Ticket wird dauerhaft gelöscht.',
          style: TextStyle(fontFamily: 'Outfit', color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen',
                style: TextStyle(
                    color: AppTheme.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await TicketService.instance.deleteTicket(_ticket.id);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _ticket.status == TicketStatus.active;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('E-Ticket'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error),
            onPressed: _delete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          children: [
            _buildTicketCard(isActive),
            const SizedBox(height: 28),
            _buildInfoGrid(),
            const SizedBox(height: 28),
            if (isActive) _buildMarkUsedButton(),
            if (!isActive) _buildStatusBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(bool isActive) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.35),
                    blurRadius: _glow.value,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: child,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.divider, width: 1),
        ),
        child: Column(
          children: [
            _buildCardHeader(),
            _buildDividerWithCircles(),
            _buildQrSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _ticket.category.label,
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryLight,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _ticket.imageEmoji,
                style: const TextStyle(fontSize: 28),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _ticket.eventName,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  color: AppTheme.textMuted, size: 14),
              const SizedBox(width: 4),
              Text(
                '${_ticket.venue}, ${_ticket.city}',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _infoChip(
                Icons.calendar_today_rounded,
                '${_ticket.eventDate.day.toString().padLeft(2, '0')}.'
                '${_ticket.eventDate.month.toString().padLeft(2, '0')}.'
                '${_ticket.eventDate.year}',
              ),
              const SizedBox(width: 10),
              _infoChip(Icons.chair_rounded,
                  '${_ticket.section} · Platz ${_ticket.seat}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.textMuted),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDividerWithCircles() {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: AppTheme.background,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: CustomPaint(painter: _DashedLinePainter()),
          ),
        ),
        Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: AppTheme.background,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildQrSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          QrWidget(data: _ticket.qrData, size: 180),
          const SizedBox(height: 14),
          Text(
            _ticket.id,
            style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 13,
              color: AppTheme.textMuted,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_ticket.price.toStringAsFixed(2)} €',
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          _infoRow('Status', _ticket.status.label,
              color: _ticket.status == TicketStatus.active
                  ? AppTheme.success
                  : AppTheme.textMuted),
          const Divider(color: AppTheme.divider, height: 24),
          _infoRow('Veranstaltungsort', _ticket.venue),
          const Divider(color: AppTheme.divider, height: 24),
          _infoRow('Datum',
              '${_ticket.eventDate.day.toString().padLeft(2, '0')}.${_ticket.eventDate.month.toString().padLeft(2, '0')}.${_ticket.eventDate.year}'),
          const Divider(color: AppTheme.divider, height: 24),
          _infoRow('Ticket-ID', _ticket.id),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                color: AppTheme.textSecondary)),
        Text(value,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color ?? AppTheme.textPrimary,
            )),
      ],
    );
  }

  Widget _buildMarkUsedButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _markUsed,
        icon: const Icon(Icons.qr_code_scanner_rounded),
        label: const Text('Ticket einlösen'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.accent,
          side: const BorderSide(color: AppTheme.accent),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.w600,
              fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _ticket.status == TicketStatus.used
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            color: _ticket.status == TicketStatus.used
                ? AppTheme.success
                : AppTheme.textMuted,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _ticket.status == TicketStatus.used
                ? 'Dieses Ticket wurde bereits eingelöst'
                : 'Dieses Ticket ist abgelaufen',
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dashed line painter ───────────────────────────────────────────────────────
class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.divider
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashW = 6.0, gapW = 5.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, size.height / 2),
          Offset(x + dashW, size.height / 2), paint);
      x += dashW + gapW;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
