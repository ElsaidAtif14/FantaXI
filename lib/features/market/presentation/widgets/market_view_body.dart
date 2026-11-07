import 'package:fantasy/features/bootstrap/data/models/bootstrap_model.dart';
import 'package:fantasy/features/bootstrap/data/models/player_model.dart';
import 'package:fantasy/features/bootstrap/presentation/cubit/bootstrap_cubit.dart';
import 'package:fantasy/features/market/presentation/widgets/market_docked_comparison_panel.dart';
import 'package:fantasy/features/market/presentation/widgets/market_player_tile.dart';
import 'package:fantasy/features/market/presentation/widgets/market_position_selector.dart';
import 'package:fantasy/features/market/presentation/widgets/market_quick_filters.dart';
import 'package:fantasy/features/market/presentation/widgets/market_sort.dart';
import 'package:fantasy/features/market/presentation/widgets/market_sort_sheet.dart';
import 'package:fantasy/features/market/presentation/widgets/market_square_button.dart';
import 'package:fantasy/features/picks/presentation/widgets/error_message_view.dart';
import 'package:fantasy/shared/widgets/app_navigation_dock.dart';
import 'package:fantasy/shared/widgets/app_snack_bar.dart';
import 'package:fantasy/shared/widgets/custom_app_bar.dart';
import 'package:fantasy/shared/widgets/custom_search_bar.dart';
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MarketViewBody extends StatefulWidget {
  const MarketViewBody({super.key});

  @override
  State<MarketViewBody> createState() => _MarketViewBodyState();
}

class _MarketViewBodyState extends State<MarketViewBody> {
  final _searchController = TextEditingController();
  final Set<int> _comparisonIds = {};
  int? _positionFilter;
  MarketSort _sort = MarketSort.points;
  bool _comparisonExpanded = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: CustomAppBar(title: 'Market', showActions: false),
      backgroundColor: context.appColors.marketBackground,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<BootstrapCubit, BootstrapState>(
            builder: (context, state) {
              final players =
                  state is BootstrapLoaded ? state.data.playersMap : {};
              final teams = state is BootstrapLoaded ? state.data.teamsMap : {};
              final compared =
                  _comparisonIds
                      .map((id) => players[id])
                      .whereType<PlayerModel>()
                      .toList();
              if (compared.isEmpty) return const SizedBox.shrink();
              return MarketDockedComparisonPanel(
                players: compared,
                teamNames: {
                  for (final player in compared)
                    player.id: teams[player.team]?.name ?? '',
                },
                expanded: _comparisonExpanded,
                onToggleExpanded:
                    () => setState(
                      () => _comparisonExpanded = !_comparisonExpanded,
                    ),
                onRemove:
                    (player) =>
                        setState(() => _comparisonIds.remove(player.id)),
              );
            },
          ),
          const AppNavigationDock(currentIndex: 2, showLive: true),
        ],
      ),
      body: BlocBuilder<BootstrapCubit, BootstrapState>(
        builder: (context, state) {
          if (state is BootstrapLoading || state is BootstrapInitial) {
            return const _MarketLoadingView();
          }
          if (state is BootstrapError) {
            return Center(
              child: ErrorMessageView(
                icon: Icons.cloud_off_outlined,
                message: state.message,
                actionLabel: 'Try again',
                onAction:
                    () => context.read<BootstrapCubit>().loadBootstrap(
                      refresh: true,
                    ),
              ),
            );
          }
          if (state is! BootstrapLoaded) return const SizedBox.shrink();

          final players = _filteredPlayers(state.data);
          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomSearchBar(
                          controller: _searchController,
                          hintText: 'Search players, clubs...',
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      MarketSquareButton(
                        icon: Icons.tune_rounded,
                        tooltip: 'Sort players',
                        onPressed: () => _showSortMenu(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                MarketPositionSelector(
                  selected: _positionFilter,
                  counts: _positionCounts(state.data),
                  onSelected:
                      (value) => setState(() => _positionFilter = value),
                ),
                const SizedBox(height: 10),
                const MarketQuickFilters(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        'AVAILABLE PLAYERS (${players.length})',
                        style:  TextStyle(
                          color: context.appColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .55,
                        ),
                      ),
                      const Spacer(),
                      if (_comparisonIds.isNotEmpty)
                        Text(
                          'Comparing ${_comparisonIds.length}/2',
                          style:  TextStyle(
                            color: context.appColors.marketLavender,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child:
                      players.isEmpty
                          ?  Center(
                            child: Text(
                              'No players match your search',
                              style: TextStyle(color: context.appColors.textSecondary),
                            ),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            itemCount: players.length,
                            itemBuilder: (context, index) {
                              final player = players[index];
                              return MarketPlayerTile(
                                player: player,
                                teamName:
                                    state.data.getTeam(player.team)?.name ?? '',
                                selected: _comparisonIds.contains(player.id),
                                onTap: () => _toggleComparison(player),
                              );
                            },
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<int?, int> _positionCounts(BootstrapModel bootstrap) {
    return {
      null: bootstrap.players.length,
      for (var position = 1; position <= 4; position++)
        position:
            bootstrap.players
                .where((player) => player.elementType == position)
                .length,
    };
  }

  void _showSortMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.appColors.marketSurface,
      builder:
          (context) => MarketSortSheet(
            selected: _sort,
            onSelected: (sort) => setState(() => _sort = sort),
          ),
    );
  }

  List<PlayerModel> _filteredPlayers(BootstrapModel bootstrap) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered =
        bootstrap.players.where((player) {
          final teamName =
              bootstrap.getTeam(player.team)?.name.toLowerCase() ?? '';
          final matchesQuery =
              query.isEmpty ||
              player.webName.toLowerCase().contains(query) ||
              player.firstName.toLowerCase().contains(query) ||
              player.secondName.toLowerCase().contains(query) ||
              teamName.contains(query);
          return matchesQuery &&
              (_positionFilter == null ||
                  player.elementType == _positionFilter);
        }).toList();

    filtered.sort(
      (first, second) => switch (_sort) {
        MarketSort.points => second.totalPoints.compareTo(first.totalPoints),
        MarketSort.form => second.form.compareTo(first.form),
        MarketSort.price => second.nowCost.compareTo(first.nowCost),
      },
    );

    return filtered;
  }

  void _toggleComparison(PlayerModel player) {
    setState(() {
      if (!_comparisonIds.add(player.id)) {
        _comparisonIds.remove(player.id);
        if (_comparisonIds.isEmpty) _comparisonExpanded = true;
      } else if (_comparisonIds.length > 2) {
        _comparisonIds.remove(player.id);
        AppSnackBar.show(
          context,
          'Compare up to two players',
          type: AppSnackBarType.warning,
        );
      }
    });
  }
}

class _MarketLoadingView extends StatelessWidget {
  const _MarketLoadingView();

  @override
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Skeletonizer(
      enabled: true,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Bone.square(
                  size: 42,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                SizedBox(width: 12),
                Expanded(child: Bone.text(words: 2, fontSize: 22)),
                Bone.square(
                  size: 36,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Bone(
              width: double.infinity,
              height: 44,
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Bone(
              width: double.infinity,
              height: 38,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: 8,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder:
                  (_, _) => Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: context.appColors.marketSurface,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      children: [
                        Bone(
                          width: 42,
                          height: 48,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Bone.text(words: 2),
                              SizedBox(height: 5),
                              Bone.text(words: 1, fontSize: 10),
                              SizedBox(height: 5),
                              Bone.text(words: 2, fontSize: 9),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Bone.text(words: 1),
                            SizedBox(height: 6),
                            Bone.text(words: 2, fontSize: 9),
                          ],
                        ),
                        SizedBox(width: 12),
                        Bone.square(
                          size: 34,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
    ),
  );
}
