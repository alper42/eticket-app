part of 'ticket_bloc.dart';

abstract class TicketState {}

/// Initaler Zustand
class TicketInitial extends TicketState {}

/// Tickets werden geladen
class TicketLoading extends TicketState {}

/// Tickets erfolgreich geladen
class TicketLoaded extends TicketState {
  final List<Ticket> tickets;
  TicketLoaded(this.tickets);

  List<Ticket> get activeTickets =>
      tickets.where((t) => t.status == TicketStatus.active).toList();

  List<Ticket> get pastTickets =>
      tickets.where((t) => t.status != TicketStatus.active).toList();

  int get todayCount =>
      activeTickets.where((t) => t.isToday).length;
}

/// Fehler beim Laden
class TicketError extends TicketState {
  final String message;
  TicketError(this.message);
}

/// Ticket wurde erfolgreich gekauft
class TicketPurchased extends TicketState {
  final List<Ticket> tickets;
  TicketPurchased(this.tickets);
}
