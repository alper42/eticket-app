import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/ticket/ticket_bloc.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';
import '../widgets/ticket_card.dart';
import '../widgets/stat_chip.dart';
import 'buy_ticket_screen.dart';
import 'ticket_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openBuy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BuyTicketScreen()),
    );
  }

  void _openDetail(Ticket ticket) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => TicketDetailScreen(ticket: ticket)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: BlocBuilder<TicketBloc, TicketState>(
          builder: (context, state) {
            if (state is TicketLoading || state is TicketInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              );
            }

            if (state is TicketError) {
              return Center(
                child: Text(state.message,
                    style: const TextStyle(color: AppTheme.error)),
              );
            }

            final loaded = state is TicketLoaded
                ? state
                : state is TicketPurchased
                    ? TicketLoaded(state.tickets)
                    : TicketLoaded(const []);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildStats(loaded),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTicketList(
                        loaded.activeTickets,
                        emptyMsg: 'Keine aktiven Tickets.\nKauf dein erstes Ticket!',
                      ),
                      _buildTicketList(
                        loaded.pastTickets,
                        emptyMsg: 'Noch keine vergangenen Tickets.',
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Meine Tickets',
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 2),
              Text(
                'Alle Events auf einen Blick',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.textMuted),
              ),
            ],
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_none_rounded,
                color: AppTheme.textSecondary, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(TicketLoaded state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          StatChip(
              label: 'Aktiv',
              value: '${state.activeTickets.length}',
              color: AppTheme.primary),
          const SizedBox(width: 10),
          StatChip(
              label: 'Heute',
              value: '${state.todayCount}',
              color: AppTheme.accent),
          const SizedBox(width: 10),
          StatChip(
              label: 'Gesamt',
              value: '${state.tickets.length}',
              color: AppTheme.textMuted),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Aktive Tickets'),
            Tab(text: 'Vergangen'),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketList(List<Ticket> tickets,
      {required String emptyMsg}) {
    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎟️', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            Text(
              emptyMsg,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.textMuted, height: 1.6),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      itemCount: tickets.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TicketCard(
          ticket: tickets[i],
          onTap: () => _openDetail(tickets[i]),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _openBuy,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text(
                  'Ticket kaufen',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
