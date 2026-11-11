import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/bootstrap/data/models/team_model.dart';
import 'package:fantasy/features/matches/data/models/fixture_model.dart';
import 'package:fantasy/features/matches/data/models/premier_league_match_details_model.dart';
import 'package:fantasy/features/matches/presentation/widgets/match_details_style.dart';
import 'package:fantasy/features/matches/presentation/widgets/match_status_pill.dart';
import 'package:fantasy/features/matches/presentation/widgets/team_crest.dart';
import 'package:flutter/material.dart';

const _heroBackground = Color(0xFF181B25);

/// The dark broadcast-style scoreboard. It intentionally keeps the same dark
/// surface in both themes as part of FantaXI's identity.
class ScoreboardHero extends StatelessWidget {
  const ScoreboardHero({
    super.key,
    required this.fixture,
    required this.details,
    required this.homeTeam,
    required this.awayTeam,
    required this.kickoff,
    required this.status,
    this.liveMinute,
  });

  final FixtureModel fixture;
  final PremierLeagueMatchDetails? details;
  final TeamModel? homeTeam;
  final TeamModel? awayTeam;
  final DateTime? kickoff;
  final MatchStatusKind status;
  final String? liveMinute;

  @override
  Widget build(BuildContext context) {
    final homeScore = details?.homeTeam?.score ?? fixture.homeScore;
    final awayScore = details?.awayTeam?.score ?? fixture.awayScore;
    final hasScore = homeScore != null && awayScore != null;
    final halfTimeHome = details?.homeTeam?.halfTimeScore;
    final halfTimeAway = details?.awayTeam?.halfTimeScore;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MatchDetailsStyle.gutter,
        MatchDetailsStyle.spaceXs,
        MatchDetailsStyle.gutter,
        0,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MatchDetailsStyle.cardRadius),
        child: Stack(
          children: [
            Positioned(
              left: -70,
              top: -90,
              child: _AmbientGlow(
                color: context.appColors.lineupPurple.withValues(alpha: .16),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _heroBackground,
                borderRadius: BorderRadius.circular(
                  MatchDetailsStyle.cardRadius,
                ),
              ),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 330;
                      final crestSize = compact ? 46.0 : 56.0;
                      final scoreSize = compact ? 34.0 : 40.0;
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          compact ? 8 : 12,
                          18,
                          compact ? 8 : 12,
                          0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _ScoreTeamBlock(
                                team: homeTeam,
                                crestSize: crestSize,
                                sideLabel: 'HOME',
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 14),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    hasScore ? '$homeScore - $awayScore' : 'vs',
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: context.appColors.lineupText,
                                      fontSize: hasScore ? scoreSize : 22,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -.6,
                                      height: 1,
                                      fontFeatures: const [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _ScoreTeamBlock(
                                team: awayTeam,
                                crestSize: crestSize,
                                sideLabel: 'AWAY',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: MatchDetailsStyle.spaceSm,
                    ),
                    child: Center(
                      child: MatchStatusPill(kind: status, minute: liveMinute),
                    ),
                  ),
                  _HeroMetaStrip(
                    kickoff: kickoff,
                    halfTimeHome: halfTimeHome,
                    halfTimeAway: halfTimeAway,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreTeamBlock extends StatelessWidget {
  const _ScoreTeamBlock({
    required this.team,
    required this.crestSize,
    required this.sideLabel,
  });

  final TeamModel? team;
  final double crestSize;
  final String sideLabel;

  @override
  Widget build(BuildContext context) {
    final name = team?.name.trim();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: crestSize + 12,
          height: crestSize + 12,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .06),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: .08)),
          ),
          child: TeamCrest(
            team: team,
            size: crestSize,
            background: Colors.white.withValues(alpha: .08),
            borderColor: Colors.white.withValues(alpha: .12),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          (name == null || name.isEmpty) ? 'Team unavailable' : name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.appColors.lineupText,
            fontSize: 12.5,
            height: 1.15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          sideLabel,
          style: TextStyle(
            color: context.appColors.lineupTextSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _HeroMetaStrip extends StatelessWidget {
  const _HeroMetaStrip({
    required this.kickoff,
    this.halfTimeHome,
    this.halfTimeAway,
  });

  final DateTime? kickoff;
  final int? halfTimeHome;
  final int? halfTimeAway;

  @override
  Widget build(BuildContext context) {
    final hasHalfTime = halfTimeHome != null && halfTimeAway != null;
    final kickoffLabel = _kickoffLabel(context);
    final label =
        hasHalfTime ? 'Half-time $halfTimeHome - $halfTimeAway' : kickoffLabel;
    if (label == null || label.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .045),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: .06)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasHalfTime ? Icons.timer_outlined : Icons.calendar_today_rounded,
            size: 12,
            color: context.appColors.lineupTextSecondary,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.appColors.lineupTextSecondary,
                fontSize: MatchDetailsStyle.labelSize,
                fontWeight: FontWeight.w600,
                letterSpacing: .2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _kickoffLabel(BuildContext context) {
    final value = kickoff;
    if (value == null) return null;
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatMediumDate(value);
    final time = TimeOfDay.fromDateTime(value).format(context);
    return '$date · $time';
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 170,
    height: 170,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: color, blurRadius: 52, spreadRadius: 24)],
    ),
  );
}
