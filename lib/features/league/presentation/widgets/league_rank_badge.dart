
import 'package:fantasy/features/league/data/models/league_response_model.dart';
import 'package:fantasy/features/league/presentation/widgets/battle_summary.dart';
import 'package:fantasy/features/league/presentation/widgets/filter_chips.dart';
import 'package:fantasy/features/league/presentation/widgets/league_header.dart';
import 'package:fantasy/features/league/presentation/widgets/league_standing_row.dart';
import 'package:fantasy/features/league/presentation/widgets/league_view_body.dart';
import 'package:fantasy/features/league/presentation/widgets/search_field.dart';
import 'package:fantasy/features/league/presentation/widgets/standings_column_header.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class LeagueLoadingView extends StatelessWidget {
  const LeagueLoadingView({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final placeholders = List.generate(
      8,
      (index) => LeagueStanding.dummy(index + 1),
    );
    final current = placeholders[3];

    return IgnorePointer(
      child: Skeletonizer(
        enabled: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            LeagueHeader(
              name: 'Loading league',
              managerCount: 142,
              onBack: () {},
              onShare: () {},
            ),
            const SizedBox(height: 10),
            BattleSummary(
              standings: placeholders,
              current: current,
              selectedTab: 0,
              onTabChanged: (_) {},
            ),
            const SizedBox(height: 12),
            SearchField(controller: controller),
            const SizedBox(height: 10),
            FilterChips(
              selected: LeagueFilter.all,
              standings: placeholders,
              current: current,
              onSelected: (_) {},
            ),
            const SizedBox(height: 10),
            const StandingsColumnHeader(),
            ...placeholders.map(
              (standing) => LeagueStandingRow(
                standing: standing,
                isCurrentUser: standing.rank == current.rank,
              ),
            ),
          ],
        ),
      ),
    );
  }
}







