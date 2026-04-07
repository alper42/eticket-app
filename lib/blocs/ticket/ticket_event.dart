part of 'ticket_bloc.dart';

abstract class TicketEvent {}

/// Lädt alle Tickets aus dem Speicher
class LoadTickets extends TicketEvent {}

/// Fügt ein neues Ticket hinzu
class AddTicket extends TicketEvent {
  final Ticket ticket;
  AddTicket(this.ticket);
}

/// Markiert ein Ticket als verwendet
class MarkTicketUsed extends TicketEvent {
  final String id;
  MarkTicketUsed(this.id);
}

/// Löscht ein Ticket
class DeleteTicket extends TicketEvent {
  final String id;
  DeleteTicket(this.id);
}
