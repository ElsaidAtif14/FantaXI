import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/home/presentation/widgets/leagues_hub_cup_match_card.dart';
import 'package:fantasy/features/home/presentation/widgets/leagues_hub_empty_state.dart';
import 'package:fantasy/features/home/presentation/widgets/leagues_hub_group_filters.dart';
import 'package:fantasy/features/home/presentation/widgets/leagues_hub_league_card.dart';
import 'package:fantasy/features/home/presentation/widgets/leagues_hub_models.dart';
import 'package:fantasy/features/home/presentation/widgets/leagues_hub_sort_button.dart';
import 'package:fantasy/features/manager/data/models/cup_match_model.dart';
import 'package:fantasy/features/manager/data/models/fantasy_manager_model.dart';
import 'package:fantasy/shared/widgets/custom_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LeaguesHubContent extends StatefulWidget {
  const LeaguesHubContent({super.key, required this.manager});

  final FantasyManagerModel manager;

  @override
  State<LeaguesHubContent> createState() => _LeaguesHubContentState();
}

class _LeaguesHubContentState extends State<LeaguesHubContent> {
  final TextEditingController _searchController = TextEditingController();
  LeaguesHubFilterGroup _group = LeaguesHubFilterGroup.all;
  bool _ascending = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = widget.manager;
    final allLeagues = [
      ...manager.globalLeagues.map(
        (league) => LeaguesHubLeagueItem(league: league, isGlobal: true),
      ),
      ...manager.classicLeagues.map(
        (league) => LeaguesHubLeagueItem(league: league, isGlobal: false),
      ),
    ];

    final filtered = _filterAndSort(allLeagues);

    // فصل القائمة المفلترة لـ Global و Private
    final globalList = filtered.where((item) => item.isGlobal).toList();
    final privateList = filtered.where((item) => !item.isGlobal).toList();

    final search = _searchController.text.trim().toLowerCase();
    final cupMatches =
        _group == LeaguesHubFilterGroup.global
            ? <CupMatchModel>[]
            : manager.cupMatches.where((cup) {
              if (cup.knockoutName.isEmpty) return false;
              if (search.isEmpty) return true;
              return cup.knockoutName.toLowerCase().contains(search) ||
                  cup.opponentName.toLowerCase().contains(search);
            }).toList();

    final featuredLeague =
        manager.classicLeagues.isEmpty ? null : manager.classicLeagues.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
         Text(
          'TACTICAL HUB',
          style: TextStyle(
            color: context.appColors.lineupLavender,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
         Text(
          'Leagues & Standings',
          style: TextStyle(
            color: context.appColors.lineupText,
            fontSize: 24,
            height: 1.15,
            fontWeight: FontWeight.w700,
            letterSpacing: -.5,
          ),
        ),
        const SizedBox(height: 24),
        LeaguesHubGroupFilters(
          selected: _group,
          allCount: allLeagues.length,
          globalCount: manager.globalLeagues.length,
          privateCount: manager.classicLeagues.length,
          onSelected: (group) => setState(() => _group = group),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomSearchBar(
                controller: _searchController,
                hintText: 'Search leagues & cups...',
              ),
            ),
            const SizedBox(width: 6),
            LeaguesHubSortButton(
              ascending: _ascending,
              onPressed: () => setState(() => _ascending = !_ascending),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty && cupMatches.isEmpty)
          const LeaguesHubEmptyState()
        else ...[
          // عرض الدوريات الخاصة Private Leagues أولاً
          ...privateList.map(
            (item) => LeaguesHubLeagueCard(
              item: item,
              managerPoints: manager.totalPoints,
              currentGameweek: manager.currentEvent,
              isFeatured: item.league.id == featuredLeague?.id,
              onTap: () => context.push('/league/${item.league.id}'),
            ),
          ),

          // الفاصل بين Private و Global
          if (_group == LeaguesHubFilterGroup.all &&
              privateList.isNotEmpty &&
              globalList.isNotEmpty) ...[
            const SizedBox(height: 12),
             Row(
              children: [
                Expanded(
                  child: Divider(
                    color: context.appColors.lineupLavender,
                    thickness: 0.8,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'GLOBAL LEAGUES',
                    style: TextStyle(
                      color: context.appColors.lineupLavender,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: context.appColors.lineupLavender,
                    thickness: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // عرض الدوريات العامة Global Leagues
          ...globalList.map(
            (item) => LeaguesHubLeagueCard(
              item: item,
              managerPoints: manager.totalPoints,
              currentGameweek: manager.currentEvent,
              isFeatured: item.league.id == featuredLeague?.id,
              onTap: () => context.push('/league/${item.league.id}'),
            ),
          ),

          // عرض الكؤوس Cup Matches
          ...cupMatches.map(
            (cup) => LeaguesHubCupMatchCard(
              cup: cup,
              onTap:
                  () => context.push(
                    '/picks?entryId=${manager.id}&gw=${cup.event}',
                  ),
            ),
          ),
        ],
      ],
    );
  }

  List<LeaguesHubLeagueItem> _filterAndSort(
    List<LeaguesHubLeagueItem> leagues,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered =
        leagues.where((item) {
          final matchesGroup = switch (_group) {
            LeaguesHubFilterGroup.all => true,
            LeaguesHubFilterGroup.global => item.isGlobal,
            LeaguesHubFilterGroup.private => !item.isGlobal,
          };
          return matchesGroup && item.league.name.toLowerCase().contains(query);
        }).toList();

    filtered.sort((a, b) {
      final aRank = a.league.rank;
      final bRank = b.league.rank;
      if (aRank == null || bRank == null) {
        if (aRank == null && bRank == null) return 0;
        return aRank == null ? 1 : -1;
      }
      return _ascending ? aRank.compareTo(bRank) : bRank.compareTo(aRank);
    });
    return filtered;
  }
}
