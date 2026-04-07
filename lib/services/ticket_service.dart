import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ticket.dart';

class TicketService {
  static const String _storageKey = 'etickets_v1';
  static TicketService? _instance;

  TicketService._();
  static TicketService get instance {
    _instance ??= TicketService._();
    return _instance!;
  }

  List<Ticket> _tickets = [];
  List<Ticket> get tickets => List.unmodifiable(_tickets);

  Future<void> loadTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final List<dynamic> list = jsonDecode(raw);
      _tickets = list.map((e) => Ticket.fromMap(e)).toList();
    } else {
      // Seed with demo tickets on first launch
      _tickets = _demoTickets();
      await _persist();
    }
    // Auto-expire tickets
    for (var i = 0; i < _tickets.length; i++) {
      if (_tickets[i].isExpired && _tickets[i].status == TicketStatus.active) {
        _tickets[i] = _tickets[i].copyWith(status: TicketStatus.expired);
      }
    }
  }

  Future<void> addTicket(Ticket ticket) async {
    _tickets.insert(0, ticket);
    await _persist();
  }

  Future<void> markAsUsed(String id) async {
    final idx = _tickets.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _tickets[idx] = _tickets[idx].copyWith(status: TicketStatus.used);
      await _persist();
    }
  }

  Future<void> deleteTicket(String id) async {
    _tickets.removeWhere((t) => t.id == id);
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_tickets.map((t) => t.toMap()).toList());
    await prefs.setString(_storageKey, raw);
  }

  List<Ticket> get activeTickets =>
      _tickets.where((t) => t.status == TicketStatus.active).toList();

  List<Ticket> get pastTickets =>
      _tickets.where((t) => t.status != TicketStatus.active).toList();

  static String generateId() {
    final rng = Random();
    return List.generate(12, (_) => rng.nextInt(36).toRadixString(36))
        .join()
        .toUpperCase();
  }

  static String generateQr(String eventName, String id) {
    return 'ETICKET:$id:${eventName.replaceAll(' ', '_').toUpperCase()}';
  }

  List<Ticket> _demoTickets() {
    final now = DateTime.now();
    return [
      Ticket(
        id: 'TK001ABC',
        eventName: 'Coldplay – Music of the Spheres',
        venue: 'Allianz Arena',
        city: 'München',
        eventDate: now.add(const Duration(days: 12)),
        seat: '14',
        section: 'Block C – Reihe 7',
        price: 119.00,
        category: TicketCategory.concert,
        status: TicketStatus.active,
        qrData: 'ETICKET:TK001ABC:COLDPLAY_MUSIC_OF_THE_SPHERES',
        imageEmoji: '🎸',
      ),
      Ticket(
        id: 'TK002XYZ',
        eventName: 'FC Bayern vs. Borussia Dortmund',
        venue: 'Allianz Arena',
        city: 'München',
        eventDate: now.add(const Duration(days: 3)),
        seat: '22',
        section: 'Südtribüne – Block S5',
        price: 75.00,
        category: TicketCategory.sport,
        status: TicketStatus.active,
        qrData: 'ETICKET:TK002XYZ:FCB_VS_BVB',
        imageEmoji: '⚽',
      ),
      Ticket(
        id: 'TK003DEF',
        eventName: 'Techno Summer Festival',
        venue: 'Olympiapark',
        city: 'München',
        eventDate: now.add(const Duration(days: 45)),
        seat: 'GA',
        section: 'Freies Gelände',
        price: 59.00,
        category: TicketCategory.festival,
        status: TicketStatus.active,
        qrData: 'ETICKET:TK003DEF:TECHNO_SUMMER_FESTIVAL',
        imageEmoji: '🎛️',
      ),
      Ticket(
        id: 'TK004GHI',
        eventName: 'Der Kirschgarten – Schauspiel',
        venue: 'Residenztheater',
        city: 'München',
        eventDate: now.subtract(const Duration(days: 10)),
        seat: 'G18',
        section: 'Parkett',
        price: 45.00,
        category: TicketCategory.theater,
        status: TicketStatus.used,
        qrData: 'ETICKET:TK004GHI:DER_KIRSCHGARTEN',
        imageEmoji: '🎭',
      ),
    ];
  }
}
