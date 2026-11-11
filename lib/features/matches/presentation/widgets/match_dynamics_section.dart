import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/bootstrap/data/models/team_model.dart';
import 'package:fantasy/features/matches/data/models/premier_league_match_details_model.dart';
import 'package:fantasy/features/matches/presentation/formatting/match_number_format.dart';
import 'package:fantasy/features/matches/presentation/widgets/comparison_bar.dart';
import 'package:fantasy/features/matches/presentation/widgets/match_details_style.dart';
import 'package:fantasy/features/matches/presentation/widgets/section_empty_state.dart';
import 'package:fantasy/features/matches/presentation/widgets/section_header.dart';
import 'package:flutter/material.dart';

/// Three headline comparisons derived from the existing statistics map.
class MatchDynamicsSection extends StatelessWidget {
  const MatchDynamicsSection({
    super.key,
    required this.details,
    required this.homeTeam,
    required this.awayTeam,
    this.loading = false,
  });

  final PremierLeagueMatchDetails? details;
  final TeamModel? homeTeam;
  final TeamModel? awayTeam;
  final bool loading;

  static const _metrics = [
    _DynamicsMetric(
      label: 'Possession',
      keys: ['possessionPercentage', 'possession'],
      percentage: true,
    ),
    _DynamicsMetric(
      label: 'Total shots',
      keys: ['totalScoringAtt', 'totalShots'],
    ),
    _DynamicsMetric(
      label: 'On target',
      keys: ['ontargetScoringAtt', 'shotsOnTarget'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final home = details?.statistics['home'];
    final away = details?.statistics['away'];
    final hasAny = home != null || away != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Match dynamics',
          trailing: hasAny ? null : (loading ? 'Loading' : 'Unavailable'),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            MatchDetailsStyle.gutter,
            MatchDetailsStyle.spaceSm,
            MatchDetailsStyle.gutter,
            0,
          ),
          child:
              (loading && details == null)
                  ? _DynamicsLoading()
                  : !hasAny
                  ? const SectionEmptyState(
                    icon: Icons.bar_chart_rounded,
                    title: 'Statistics unavailable',
                    message:
                        'Verified match statistics are not available for this fixture yet.',
                  )
                  : _DynamicsPanel(
                    home: home,
                    away: away,
                    homeTeam: homeTeam,
                    awayTeam: awayTeam,
                  ),
        ),
      ],
    );
  }
}

class _DynamicsLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    height: 96,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: context.appColors.lineupPanel,
      borderRadius: BorderRadius.circular(MatchDetailsStyle.panelRadius),
    ),
    child: const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  );
}

class _DynamicsPanel extends StatelessWidget {
  const _DynamicsPanel({
    required this.home,
    required this.away,
    required this.homeTeam,
    required this.awayTeam,
  });

  final Map<String, num>? home;
  final Map<String, num>? away;
  final TeamModel? homeTeam;
  final TeamModel? awayTeam;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: context.appColors.lineupPanel,
        borderRadius: BorderRadius.circular(MatchDetailsStyle.panelRadius),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '${_sideLabel(homeTeam, 'HOME')} · H',
                style: _legendStyle(context, context.appColors.matchHome),
              ),
              const Spacer(),
              Text(
                '${_sideLabel(awayTeam, 'AWAY')} · A',
                style: _legendStyle(context, context.appColors.matchAway),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < MatchDynamicsSection._metrics.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _DynamicsRow(
              metric: MatchDynamicsSection._metrics[i],
              homeValue: _value(home, MatchDynamicsSection._metrics[i]),
              awayValue: _value(away, MatchDynamicsSection._metrics[i]),
            ),
          ],
        ],
      ),
    );
  }

  static String _sideLabel(TeamModel? team, String fallback) {
    final short = team?.shortName.trim() ?? '';
    return short.isEmpty ? fallback : short;
  }

  static TextStyle _legendStyle(BuildContext context, Color color) => TextStyle(
    color: color,
    fontSize: MatchDetailsStyle.microSize,
    fontWeight: FontWeight.w800,
    letterSpacing: .4,
  );

  num? _value(Map<String, num>? stats, _DynamicsMetric metric) {
    if (stats == null) return null;
    for (final key in metric.keys) {
      final value = stats[key];
      if (value != null) return value;
    }
    return null;
  }
}

class _DynamicsRow extends StatelessWidget {
  const _DynamicsRow({required this.metric, this.homeValue, this.awayValue});

  final _DynamicsMetric metric;
  final num? homeValue;
  final num? awayValue;

  String? _format(num? value) {
    if (value == null) return null;
    return metric.percentage
        ? formatPercentage(value)
        : formatMatchNumber(value);
  }

  @override
  Widget build(BuildContext context) {
    final homeText = _format(homeValue) ?? '—';
    final awayText = _format(awayValue) ?? '—';
    final hasValues = homeValue != null && awayValue != null;
    return Semantics(
      label: '${metric.label}: home $homeText, away $awayText',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  homeText,
                  style: TextStyle(
                    color: context.appColors.lineupText,
                    fontSize: MatchDetailsStyle.emphasisSize,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  metric.label.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.appColors.lineupTextSecondary,
                    fontSize: MatchDetailsStyle.microSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .35,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  awayText,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: context.appColors.lineupText,
                    fontSize: MatchDetailsStyle.emphasisSize,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ComparisonBar(
            homeValue: hasValues ? homeValue! : 0,
            awayValue: hasValues ? awayValue! : 0,
          ),
        ],
      ),
    );
  }
}

class _DynamicsMetric {
  const _DynamicsMetric({
    required this.label,
    required this.keys,
    this.percentage = false,
  });

  final String label;
  final List<String> keys;
  final bool percentage;
}
