import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/league/data/models/league_response_model.dart';
import 'package:fantasy/features/league/presentation/cubit/league_cubit.dart';
import 'package:fantasy/features/league/presentation/widgets/battle_summary.dart';
import 'package:fantasy/features/league/presentation/widgets/filter_chips.dart';
import 'package:fantasy/features/league/presentation/widgets/league_header.dart';
import 'package:fantasy/features/league/presentation/widgets/league_rank_badge.dart';
import 'package:fantasy/features/league/presentation/widgets/league_standing_row.dart';
import 'package:fantasy/features/league/presentation/widgets/load_more_standings_button.dart';
import 'package:fantasy/features/league/presentation/widgets/search_field.dart';
import 'package:fantasy/features/league/presentation/widgets/standings_column_header.dart';
import 'package:fantasy/shared/widgets/app_navigation_dock.dart';
import 'package:fantasy/shared/cubit/dock_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeagueViewBody extends StatefulWidget {
  const LeagueViewBody({super.key});

  @override
  State<LeagueViewBody> createState() => _LeagueViewBodyState();
}

class _LeagueViewBodyState extends State<LeagueViewBody> {
  final TextEditingController _searchController = TextEditingController();
  late final ScrollController _scrollController;
  int? _entryId;
  bool _showGameweek = false;
  LeagueFilter _filter = LeagueFilter.all;
  bool _isCurrentRoute = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
    _loadEntryId();
    _searchController.addListener(_refresh);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    if (_isCurrentRoute) context.read<DockCubit>().show();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients || !_isCurrentRoute) return;
    context.read<DockCubit>().handleScroll(
      _scrollController.position.userScrollDirection,
    );
  }

  Future<void> _loadEntryId() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _entryId = prefs.getInt(AppConstants.entryIdKey));
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _searchController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppNavigationDock(currentIndex: -1),
      body: SafeArea(
        child: BlocBuilder<LeagueCubit, LeagueState>(
          builder: (context, state) {
            if (state is LeagueLoading || state is LeagueInitial) {
              return LeagueLoadingView(
                controller: _searchController,
                scrollController: _scrollController,
              );
            }
            if (state is LeagueError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style:  TextStyle(color: context.appColors.textPrimary),
                  ),
                ),
              );
            }
            if (state is! LeagueLoaded) return const SizedBox.shrink();

            final response = state.response;
            final standings = response.standings;
            final current = _findCurrentStanding(standings);
            final sorted = [...standings]
              ..sort(
                (a, b) => _showGameweek
                    ? b.eventTotal.compareTo(a.eventTotal)
                    : a.rank.compareTo(b.rank),
              );
            final visible = _applyFilters(sorted, standings, current);

            return ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              children: [
                LeagueHeader(
                  name: response.league.name,
                  managerCount: standings.length,
                  onBack: () => context.pop(),
                  onShare: () => _copyLeagueId(response.league.id),
                ),
                const SizedBox(height: 10),
                BattleSummary(
                  standings: standings,
                  current: current,
                  selectedTab: _showGameweek ? 1 : 0,
                  onTabChanged: (index) =>
                      setState(() => _showGameweek = index == 1),
                ),
                const SizedBox(height: 12),
                SearchField(controller: _searchController),
                const SizedBox(height: 10),
                FilterChips(
                  selected: _filter,
                  standings: standings,
                  current: current,
                  onSelected: (value) => setState(() => _filter = value),
                ),
                const SizedBox(height: 10),
                const StandingsColumnHeader(),
                if (visible.isEmpty)
                   Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'No managers match your search.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.appColors.textSecondary),
                    ),
                  )
                else
                  ...visible.map(
                    (standing) => LeagueStandingRow(
                      standing: standing,
                      isCurrentUser: standing.entryId == _entryId,
                      gameweekSelected: _showGameweek,
                    ),
                  ),
                if (state.isLoadingMore)
                   Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child:CupertinoActivityIndicator(
                        color: context.appColors.primary,
                      )
                    ),
                  )
                else if (response.hasNextPage || state.paginationError != null)
                  LoadMoreStandingsButton(
                    hasError: state.paginationError != null,
                    onPressed: () => context.read<LeagueCubit>().loadNextPage(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  LeagueStanding? _findCurrentStanding(List<LeagueStanding> standings) {
    if (_entryId == null) return null;
    for (final standing in standings) {
      if (standing.entryId == _entryId) return standing;
    }
    return null;
  }

  List<LeagueStanding> _applyFilters(
    List<LeagueStanding> sorted,
    List<LeagueStanding> all,
    LeagueStanding? current,
  ) {
    Iterable<LeagueStanding> result = sorted;
    switch (_filter) {
      case LeagueFilter.topTen:
        result = result.where((standing) => standing.rank <= 10);
        break;
      case LeagueFilter.nearMe:
        if (current != null) {
          result = result.where(
            (standing) => (standing.rank - current.rank).abs() <= 5,
          );
        }
        break;
      case LeagueFilter.rivals:
        final rivals = [...all]
          ..removeWhere((standing) => standing.entryId == current?.entryId)
          ..sort((a, b) {
            final currentRank = current?.rank ?? 1;
            final byDistance = (a.rank - currentRank).abs().compareTo(
              (b.rank - currentRank).abs(),
            );
            return byDistance != 0 ? byDistance : a.rank.compareTo(b.rank);
          });
        final rivalIds = rivals.take(4).map((standing) => standing.entryId);
        result = result.where((standing) => rivalIds.contains(standing.entryId));
        break;
      case LeagueFilter.all:
        break;
    }

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where(
        (standing) =>
            standing.playerName.toLowerCase().contains(query) ||
            standing.teamName.toLowerCase().contains(query),
      );
    }
    return result.toList();
  }

  Future<void> _copyLeagueId(int leagueId) async {
    await Clipboard.setData(ClipboardData(text: '$leagueId'));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('League ID copied to clipboard')),
    );
  }
}

enum LeagueFilter { all, topTen, nearMe, rivals }
