import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';
import '../theme/app_theme.dart';

class BuyTicketScreen extends StatefulWidget {
  const BuyTicketScreen({super.key});

  @override
  State<BuyTicketScreen> createState() => _BuyTicketScreenState();
}

class _BuyTicketScreenState extends State<BuyTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventCtrl   = TextEditingController();
  final _venueCtrl   = TextEditingController();
  final _cityCtrl    = TextEditingController();
  final _seatCtrl    = TextEditingController();
  final _sectionCtrl = TextEditingController();
  final _priceCtrl   = TextEditingController();

  TicketCategory _category = TicketCategory.concert;
  DateTime _eventDate = DateTime.now().add(const Duration(days: 30));
  bool _buying = false;

  static const Map<TicketCategory, String> _catEmojis = {
    TicketCategory.concert:    '🎵',
    TicketCategory.sport:      '⚽',
    TicketCategory.theater:    '🎭',
    TicketCategory.festival:   '🎪',
    TicketCategory.cinema:     '🎬',
    TicketCategory.conference: '💼',
  };

  @override
  void dispose() {
    _eventCtrl.dispose();
    _venueCtrl.dispose();
    _cityCtrl.dispose();
    _seatCtrl.dispose();
    _sectionCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primary,
            onPrimary: Colors.white,
            surface: AppTheme.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  Future<void> _buy() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _buying = true);

    await Future.delayed(const Duration(milliseconds: 900)); // simulate network

    final id = TicketService.generateId();
    final ticket = Ticket(
      id: id,
      eventName: _eventCtrl.text.trim(),
      venue: _venueCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      eventDate: _eventDate,
      seat: _seatCtrl.text.trim(),
      section: _sectionCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.replaceAll(',', '.')),
      category: _category,
      qrData: TicketService.generateQr(_eventCtrl.text.trim(), id),
      imageEmoji: _catEmojis[_category] ?? '🎟️',
    );

    await TicketService.instance.addTicket(ticket);

    if (mounted) {
      HapticFeedback.lightImpact();
      _showSuccess();
    }
  }

  void _showSuccess() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✅', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text('Ticket gekauft!',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Dein E-Ticket wurde erfolgreich gespeichert.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close sheet
                  Navigator.pop(context, true); // return to home
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Zu meinen Tickets',
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w600,
                        fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Ticket kaufen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          children: [
            _sectionLabel('Kategorie'),
            const SizedBox(height: 10),
            _categorySelector(),
            const SizedBox(height: 24),
            _sectionLabel('Event-Daten'),
            const SizedBox(height: 10),
            _field(_eventCtrl, 'Eventname', Icons.event_rounded,
                hint: 'z.B. Coldplay – Music of the Spheres'),
            const SizedBox(height: 12),
            _field(_venueCtrl, 'Veranstaltungsort', Icons.location_on_rounded,
                hint: 'z.B. Allianz Arena'),
            const SizedBox(height: 12),
            _field(_cityCtrl, 'Stadt', Icons.location_city_rounded,
                hint: 'z.B. München'),
            const SizedBox(height: 12),
            _datePicker(),
            const SizedBox(height: 24),
            _sectionLabel('Sitzplatz'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _field(_seatCtrl, 'Platz', Icons.chair_rounded,
                    hint: 'z.B. 14')),
                const SizedBox(width: 12),
                Expanded(child: _field(_sectionCtrl, 'Bereich', Icons.grid_view_rounded,
                    hint: 'z.B. Block C')),
              ],
            ),
            const SizedBox(height: 24),
            _sectionLabel('Preis'),
            const SizedBox(height: 10),
            _field(_priceCtrl, 'Preis (€)', Icons.euro_rounded,
                hint: '0.00',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Bitte Preis eingeben';
                  final d = double.tryParse(v.replaceAll(',', '.'));
                  if (d == null || d < 0) return 'Ungültiger Preis';
                  return null;
                }),
            const SizedBox(height: 36),
            _buyButton(),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textMuted,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _categorySelector() {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: TicketCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final cat = TicketCategory.values[i];
          final selected = cat == _category;
          return GestureDetector(
            onTap: () => setState(() => _category = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: selected
                    ? null
                    : Border.all(color: AppTheme.divider, width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_catEmojis[cat] ?? '🎟️',
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(cat.label,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: selected ? Colors.white : AppTheme.textSecondary,
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(
          fontFamily: 'Outfit', color: AppTheme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 20),
        labelStyle: const TextStyle(
            fontFamily: 'Outfit', color: AppTheme.textSecondary, fontSize: 14),
        hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
        filled: true,
        fillColor: AppTheme.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.error),
        ),
      ),
      validator: validator ??
          (v) => (v == null || v.trim().isEmpty) ? 'Pflichtfeld' : null,
    );
  }

  Widget _datePicker() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                color: AppTheme.textMuted, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Datum',
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 12,
                        color: AppTheme.textSecondary)),
                Text(
                  '${_eventDate.day.toString().padLeft(2, '0')}.'
                  '${_eventDate.month.toString().padLeft(2, '0')}.'
                  '${_eventDate.year}',
                  style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textMuted, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buyButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF6D28D9)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _buying ? null : _buy,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: _buying
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text(
                      'Jetzt kaufen  →',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
