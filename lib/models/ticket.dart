import 'dart:convert';

enum TicketStatus { active, used, expired }

enum TicketCategory { concert, sport, theater, festival, cinema, conference }

class Ticket {
  final String id;
  final String eventName;
  final String venue;
  final String city;
  final DateTime eventDate;
  final String seat;
  final String section;
  final double price;
  final TicketCategory category;
  TicketStatus status;
  final String qrData;
  final String imageEmoji; // placeholder for event image

  Ticket({
    required this.id,
    required this.eventName,
    required this.venue,
    required this.city,
    required this.eventDate,
    required this.seat,
    required this.section,
    required this.price,
    required this.category,
    this.status = TicketStatus.active,
    required this.qrData,
    required this.imageEmoji,
  });

  bool get isExpired => eventDate.isBefore(DateTime.now());
  bool get isToday {
    final now = DateTime.now();
    return eventDate.year == now.year &&
        eventDate.month == now.month &&
        eventDate.day == now.day;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventName': eventName,
      'venue': venue,
      'city': city,
      'eventDate': eventDate.toIso8601String(),
      'seat': seat,
      'section': section,
      'price': price,
      'category': category.index,
      'status': status.index,
      'qrData': qrData,
      'imageEmoji': imageEmoji,
    };
  }

  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'],
      eventName: map['eventName'],
      venue: map['venue'],
      city: map['city'],
      eventDate: DateTime.parse(map['eventDate']),
      seat: map['seat'],
      section: map['section'],
      price: (map['price'] as num).toDouble(),
      category: TicketCategory.values[map['category']],
      status: TicketStatus.values[map['status']],
      qrData: map['qrData'],
      imageEmoji: map['imageEmoji'],
    );
  }

  String toJson() => jsonEncode(toMap());
  factory Ticket.fromJson(String source) =>
      Ticket.fromMap(jsonDecode(source));

  Ticket copyWith({TicketStatus? status}) {
    return Ticket(
      id: id,
      eventName: eventName,
      venue: venue,
      city: city,
      eventDate: eventDate,
      seat: seat,
      section: section,
      price: price,
      category: category,
      status: status ?? this.status,
      qrData: qrData,
      imageEmoji: imageEmoji,
    );
  }
}

// Category helpers
extension TicketCategoryExt on TicketCategory {
  String get label {
    switch (this) {
      case TicketCategory.concert:    return 'Konzert';
      case TicketCategory.sport:      return 'Sport';
      case TicketCategory.theater:    return 'Theater';
      case TicketCategory.festival:   return 'Festival';
      case TicketCategory.cinema:     return 'Kino';
      case TicketCategory.conference: return 'Konferenz';
    }
  }

  String get emoji {
    switch (this) {
      case TicketCategory.concert:    return '🎵';
      case TicketCategory.sport:      return '⚽';
      case TicketCategory.theater:    return '🎭';
      case TicketCategory.festival:   return '🎪';
      case TicketCategory.cinema:     return '🎬';
      case TicketCategory.conference: return '💼';
    }
  }
}

extension TicketStatusExt on TicketStatus {
  String get label {
    switch (this) {
      case TicketStatus.active:  return 'Aktiv';
      case TicketStatus.used:    return 'Verwendet';
      case TicketStatus.expired: return 'Abgelaufen';
    }
  }
}
