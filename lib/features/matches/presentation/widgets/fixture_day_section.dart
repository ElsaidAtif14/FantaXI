import 'package:fantasy/core/theme/app_colors.dart';
import 'package:fantasy/features/bootstrap/data/models/team_model.dart';
import 'package:fantasy/features/matches/data/models/fixture_model.dart';
import 'package:fantasy/features/matches/presentation/widgets/fixture_card.dart';
import 'package:flutter/material.dart';

class FixtureDaySection extends StatelessWidget {
  const FixtureDaySection({
    super.key,
    required this.dateLabel,
    required this.fixtures,
    required this.teams,
  });

  final String dateLabel;
  final List<FixtureModel> fixtures;
  final Map<int, TeamModel> teams;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dateLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.lineupText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${fixtures.length} ${fixtures.length == 1 ? 'MATCH' : 'MATCHES'}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: .5,
                  ),
                ),
              ],
            ),
          ),
          for (final fixture in fixtures)
            FixtureCard(
              key: ValueKey(fixture.id),
              fixture: fixture,
              homeTeam:
                  fixture.homeTeamId == null ? null : teams[fixture.homeTeamId],
              awayTeam:
                  fixture.awayTeamId == null ? null : teams[fixture.awayTeamId],
            ),
        ],
      ),
    );
  }
}
