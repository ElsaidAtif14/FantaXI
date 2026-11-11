import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/matches/data/models/fixture_model.dart';
import 'package:fantasy/features/matches/data/models/premier_league_match_details_model.dart';
import 'package:fantasy/features/matches/presentation/formatting/match_number_format.dart';
import 'package:fantasy/features/matches/presentation/widgets/match_details_style.dart';
import 'package:fantasy/features/matches/presentation/widgets/section_header.dart';
import 'package:flutter/material.dart';

/// Compact facts block built entirely from real data. Missing values are
/// omitted instead of rendering rows of "unavailable".
class MatchFactsSection extends StatelessWidget {
  const MatchFactsSection({
    super.key,
    required this.fixture,
    required this.details,
    required this.kickoff,
  });

  final FixtureModel fixture;
  final PremierLeagueMatchDetails? details;
  final DateTime? kickoff;

  @override
  Widget build(BuildContext context) {
    final matchweek = details?.matchweek ?? fixture.gameweek;
    final facts = <_Fact>[
      if (kickoff != null)
        _Fact(
          Icons.calendar_today_rounded,
          'Date',
          MaterialLocalizations.of(context).formatMediumDate(kickoff!),
        ),
      if (kickoff != null)
        _Fact(
          Icons.schedule_rounded,
          'Kick-off',
          TimeOfDay.fromDateTime(kickoff!).format(context),
        ),
      if ((details?.stadium ?? '').trim().isNotEmpty)
        _Fact(Icons.stadium_rounded, 'Venue', details!.stadium!.trim()),
      if (matchweek != null)
        _Fact(Icons.flag_outlined, 'Matchweek', '$matchweek'),
      if ((details?.referee ?? '').trim().isNotEmpty)
        _Fact(Icons.sports_rounded, 'Referee', details!.referee!.trim()),
      if (details?.attendance != null)
        _Fact(
          Icons.groups_rounded,
          'Attendance',
          formatMatchNumber(details!.attendance!),
        ),
    ];

    if (facts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Match facts'),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            MatchDetailsStyle.gutter,
            MatchDetailsStyle.spaceSm,
            MatchDetailsStyle.gutter,
            0,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.appColors.lineupPanel,
              borderRadius: BorderRadius.circular(
                MatchDetailsStyle.panelRadius,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 460 ? 3 : 2;
                final spacing = 12.0;
                final itemWidth =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: 14,
                  children: [
                    for (final fact in facts)
                      SizedBox(width: itemWidth, child: _FactItem(fact: fact)),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Fact {
  const _Fact(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

class _FactItem extends StatelessWidget {
  const _FactItem({required this.fact});

  final _Fact fact;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(
            fact.icon,
            size: 11,
            color: context.appColors.lineupTextSecondary,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              fact.label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.appColors.lineupTextSecondary,
                fontSize: MatchDetailsStyle.microSize,
                fontWeight: FontWeight.w700,
                letterSpacing: .5,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 3),
      Text(
        fact.value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: context.appColors.lineupText,
          fontSize: MatchDetailsStyle.bodySize,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
      ),
    ],
  );
}
