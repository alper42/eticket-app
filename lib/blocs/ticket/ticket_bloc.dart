import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/ticket.dart';
import '../../services/ticket_service.dart';

part 'ticket_event.dart';
part 'ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final TicketService _service;

  TicketBloc({TicketService? service})
      : _service = service ?? TicketService.instance,
        super(TicketInitial()) {
    on<LoadTickets>(_onLoad);
    on<AddTicket>(_onAdd);
    on<MarkTicketUsed>(_onMarkUsed);
    on<DeleteTicket>(_onDelete);
  }

  Future<void> _onLoad(LoadTickets event, Emitter<TicketState> emit) async {
    emit(TicketLoading());
    try {
      await _service.loadTickets();
      emit(TicketLoaded(List.from(_service.tickets)));
    } catch (e) {
      emit(TicketError('Fehler beim Laden der Tickets: $e'));
    }
  }

  Future<void> _onAdd(AddTicket event, Emitter<TicketState> emit) async {
    try {
      await _service.addTicket(event.ticket);
      emit(TicketPurchased(List.from(_service.tickets)));
    } catch (e) {
      emit(TicketError('Fehler beim Speichern: $e'));
    }
  }

  Future<void> _onMarkUsed(
      MarkTicketUsed event, Emitter<TicketState> emit) async {
    try {
      await _service.markAsUsed(event.id);
      emit(TicketLoaded(List.from(_service.tickets)));
    } catch (e) {
      emit(TicketError('Fehler beim Einlösen: $e'));
    }
  }

  Future<void> _onDelete(DeleteTicket event, Emitter<TicketState> emit) async {
    try {
      await _service.deleteTicket(event.id);
      emit(TicketLoaded(List.from(_service.tickets)));
    } catch (e) {
      emit(TicketError('Fehler beim Löschen: $e'));
    }
  }
}
