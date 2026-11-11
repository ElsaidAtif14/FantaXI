import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/bootstrap/data/models/team_model.dart';
import 'package:fantasy/features/matches/data/models/premier_league_match_details_model.dart';
import 'package:fantasy/features/matches/presentation/formatting/match_stats_catalog.dart';
import 'package:fantasy/features/matches/presentation/widgets/comparison_bar.dart';
import 'package:fantasy/features/matches/presentation/widgets/match_details_style.dart';
import 'package:fantasy/features/matches/presentation/widgets/section_empty_state.dart';
import 'package:flutter/material.dart';

/// Match statistics tab: headline comparisons followed by grouped,
/// collapsible sections. Unknown API keys still appear, under "Other
/// statistics", so no data is ever hidden.
class StatisticsView extends StatefulWidget {
  const StatisticsView({
    super.key,
    required this.details,
    required this.homeTeam,
    required this.awayTeam,
  });

  final PremierLeagueMatchDetails? details;
  final TeamModel? homeTeam;
  final TeamModel? awayTeam;

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  bool _showAll = false;

  Map<String, num> get _home => widget.details?.statistics['home'] ?? const {};
  Map<String, num> get _away => widget.details?.statistics['away'] ?? const {};

  List<String> get _keys {
    final keys = {..._home.keys, ..._away.keys}.toList()..sort();
    return keys;
  }

  @override
  Widget build(BuildContext context) {
    final keys = _keys;
    if (keys.isEmpty) {
      return const SectionEmptyState(
        icon: Icons.bar_chart_rounded,
        title: 'Stats unavailable',
        message:
            'Verified match statistics are not available for this fixture.',
      );
    }

    final headlineKeys = <String>[];
    final grouped = <StatGroup, List<String>>{
      for (final group in StatGroup.values) group: <String>[],
    };
    for (final key in keys) {
      final definition = statDefinitionFor(key);
      if (definition == null) {
        grouped[StatGroup.other]!.add(key);
        continue;
      }
      if (definition.headline) {
        headlineKeys.add(key);
        continue;
      }
      grouped[definition.group]!.add(key);
    }
    grouped.removeWhere((group, rows) => rows.isEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TeamHeader(homeTeam: widget.homeTeam, awayTeam: widget.awayTeam),
        for (final key in headlineKeys)
          _StatRow(
            key: ValueKey(key),
            statKey: key,
            label: statDefinitionFor(key)?.label ?? humanizeStatKey(key),
            homeValue: _home[key],
            awayValue: _away[key],
          ),
        const SizedBox(height: MatchDetailsStyle.spaceMd),
        for (final entry in grouped.entries)
          _StatGroup(
            key: ValueKey('${entry.key.name}-$_showAll'),
            group: entry.key,
            keys: entry.value,
            home: _home,
            away: _away,
            initiallyExpanded: _showAll || entry.key == StatGroup.matchFlow,
          ),
        const SizedBox(height: MatchDetailsStyle.spaceLg),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _showAll = !_showAll),
            child: Text(
              _showAll ? 'Show fewer statistics' : 'Show all statistics',
            ),
          ),
        ),
      ],
    );
  }
}

class _TeamHeader extends StatelessWidget {
  const _TeamHeader({required this.homeTeam, required this.awayTeam});

  final TeamModel? homeTeam;
  final TeamModel? awayTeam;

  @override
  Widget build(BuildContext context) {
    final home = _label(homeTeam, 'HOME');
    final away = _label(awayTeam, 'AWAY');
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Row(
        children: [
          Flexible(
            child: Text(
              home,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.appColors.matchHome,
                fontSize: MatchDetailsStyle.microSize,
                fontWeight: FontWeight.w800,
                letterSpacing: .1,
              ),
            ),
          ),
          const SizedBox(width: MatchDetailsStyle.spaceMd),
          Flexible(
            child: Text(
              away,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: context.appColors.matchAway,
                fontSize: MatchDetailsStyle.microSize,
                fontWeight: FontWeight.w800,
                letterSpacing: .1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _label(TeamModel? team, String fallback) {
    final short = team?.shortName.trim() ?? '';
    return short.isEmpty ? fallback : short;
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    super.key,
    required this.statKey,
    required this.label,
    required this.homeValue,
    required this.awayValue,
  });

  final String statKey;
  final String label;
  final num? homeValue;
  final num? awayValue;

  @override
  Widget build(BuildContext context) {
    final homeText =
        homeValue == null ? '—' : formatStatValue(statKey, homeValue!);
    final awayText =
        awayValue == null ? '—' : formatStatValue(statKey, awayValue!);
    final hasBoth = homeValue != null && awayValue != null;
    return Semantics(
      label: '$label: home $homeText, away $awayText',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    homeText,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: context.appColors.lineupText,
                      fontSize: MatchDetailsStyle.bodyStrongSize,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.appColors.lineupTextSecondary,
                      fontSize: MatchDetailsStyle.microSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .25,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    awayText,
                    style: TextStyle(
                      color: context.appColors.lineupText,
                      fontSize: MatchDetailsStyle.bodyStrongSize,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ComparisonBar(
              homeValue: homeValue ?? 0,
              awayValue: awayValue ?? 0,
              height: 4,
            ),
            if (!hasBoth) const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}

class _StatGroup extends StatefulWidget {
  const _StatGroup({
    super.key,
    required this.group,
    required this.keys,
    required this.home,
    required this.away,
    required this.initiallyExpanded,
  });

  final StatGroup group;
  final List<String> keys;
  final Map<String, num> home;
  final Map<String, num> away;
  final bool initiallyExpanded;

  @override
  State<_StatGroup> createState() => _StatGroupState();
}

class _StatGroupState extends State<_StatGroup> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (final key in widget.keys) {
      final definition = statDefinitionFor(key);
      if (definition?.headline ?? false) continue;
      final homeValue = widget.home[key];
      final awayValue = widget.away[key];
      final value = homeValue ?? awayValue;
      if (value == null) continue;
      rows.add(
        _CompactStat(
          key: ValueKey(key),
          label: definition?.label ?? humanizeStatKey(key),
          homeText: homeValue == null ? '—' : formatStatValue(key, homeValue),
          awayText: awayValue == null ? '—' : formatStatValue(key, awayValue),
        ),
      );
    }
    if (rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: MatchDetailsStyle.spaceSm),
      child: Container(
        decoration: BoxDecoration(
          color: context.appColors.lineupPanel,
          borderRadius: BorderRadius.circular(MatchDetailsStyle.panelRadius),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(
                MatchDetailsStyle.panelRadius,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.group.label.toUpperCase(),
                        style: TextStyle(
                          color: context.appColors.lineupTextSecondary,
                          fontSize: MatchDetailsStyle.microSize,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .7,
                        ),
                      ),
                    ),
                    Text(
                      '${widget.keys.length}',
                      style: TextStyle(
                        color: context.appColors.lineupTextSecondary,
                        fontSize: MatchDetailsStyle.microSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: _expanded ? .5 : 0,
                      duration: const Duration(milliseconds: 160),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: context.appColors.lineupTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              duration:
                  (MediaQuery.maybeOf(context)?.disableAnimations ?? false)
                      ? Duration.zero
                      : const Duration(milliseconds: 160),
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Column(children: rows),
              ),
              crossFadeState:
                  _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactStat extends StatelessWidget {
  const _CompactStat({
    super.key,
    required this.label,
    required this.homeText,
    required this.awayText,
  });

  final String label;
  final String homeText;
  final String awayText;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$label: home $homeText, away $awayText',
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              homeText,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: context.appColors.lineupText,
                fontSize: MatchDetailsStyle.bodySize,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.appColors.lineupTextSecondary,
                fontSize: MatchDetailsStyle.microSize,
                fontWeight: FontWeight.w500,
                letterSpacing: .2,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              awayText,
              style: TextStyle(
                color: context.appColors.lineupText,
                fontSize: MatchDetailsStyle.bodySize,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
