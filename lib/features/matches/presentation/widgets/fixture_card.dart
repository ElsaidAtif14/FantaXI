import 'package:cached_network_image/cached_network_image.dart';
import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/features/bootstrap/data/models/team_model.dart';
import 'package:fantasy/features/matches/data/models/fixture_model.dart';
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class FixtureCard extends StatelessWidget {
  const FixtureCard({
    super.key,
    required this.fixture,
    required this.homeTeam,
    required this.awayTeam,
    this.onTap,
  });

  final FixtureModel fixture;
  final TeamModel? homeTeam;
  final TeamModel? awayTeam;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final kickoff = fixture.kickoffTime?.toLocal();
    final isFinished = fixture.finished == true;
    final isLive = fixture.started == true && !isFinished;
    final hasScore = fixture.homeScore != null && fixture.awayScore != null;
    final status = _status(isFinished, isLive);

    return Material(
      color: Colors.transparent,
      child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appColors.lineupSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appColors.outline.withValues(alpha: .5)),
      ),
      child: Column(
        children: [
          Text(
            status,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isLive ? context.appColors.lineupMint : context.appColors.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: .5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TeamLabel(
                  team: homeTeam,
                  alignment: CrossAxisAlignment.start,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  width: 94,
                  child: Column(
                    children: [
                      Text(
                        isFinished || isLive
                            ? hasScore
                                ? '${fixture.homeScore}  -  ${fixture.awayScore}'
                                : '—  -  —'
                            : kickoff == null
                            ? '—'
                            : TimeOfDay.fromDateTime(kickoff).format(context),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color:
                              isLive
                                  ? context.appColors.lineupMint
                                  : context.appColors.lineupText,
                          fontWeight: FontWeight.w800,
                          letterSpacing: isFinished || isLive ? 1.1 : 0,
                        ),
                      ),
                      if (!isFinished && !isLive)
                        Text(
                          kickoff == null ? 'TIME TBC' : 'KICK OFF',
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color: context.appColors.textSecondary,
                            fontSize: 9,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: _TeamLabel(
                  team: awayTeam,
                  alignment: CrossAxisAlignment.end,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    )));
  }

  String _status(bool isFinished, bool isLive) {
    if (isFinished) return 'FULL TIME';
    if (isLive) {
      final minutes = fixture.minutes;
      return minutes != null && minutes > 0 ? 'LIVE · $minutes\'' : 'LIVE';
    }
    return 'UPCOMING';
  }
}

class _TeamLabel extends StatelessWidget {
  const _TeamLabel({
    required this.team,
    required this.alignment,
    this.textAlign = TextAlign.left,
  });

  final TeamModel? team;
  final CrossAxisAlignment alignment;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final name = team?.name ?? 'Team unavailable';
    final teamCode = int.tryParse(team?.code ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _TeamBadge(teamCode: teamCode),
        const SizedBox(height: 6),
        Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.appColors.lineupText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TeamBadge extends StatelessWidget {
  const _TeamBadge({required this.teamCode});

  final int? teamCode;

  @override
  Widget build(BuildContext context) {
    const size = 36.0;
    final fallback = Container(
      width: size,
      height: size,
      decoration:  BoxDecoration(
        color: context.appColors.lineupPanel,
        shape: BoxShape.circle,
      ),
      child:  Icon(
        Icons.shield_rounded,
        color: context.appColors.lineupLavender,
        size: 21,
      ),
    );

    if (teamCode == null || teamCode! <= 0) return fallback;

    return CachedNetworkImage(
      imageUrl: '${AppConstants.teamBadgeBase}$teamCode.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => fallback,
    );
  }
}
