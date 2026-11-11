import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/bootstrap/data/models/team_model.dart';
import 'package:fantasy/features/matches/data/models/premier_league_match_details_model.dart';
import 'package:fantasy/features/matches/presentation/widgets/match_details_style.dart';
import 'package:fantasy/features/matches/presentation/widgets/section_empty_state.dart';
import 'package:flutter/material.dart';

enum _EventSide { home, away, unknown }

/// Two-sided match timeline on regular phone widths, with a single-sided
/// fallback on very narrow screens. Every parsed event is rendered exactly
/// once, including events whose team cannot be resolved.
class TimelineView extends StatefulWidget {
  const TimelineView({
    super.key,
    required this.details,
    required this.homeTeam,
    required this.awayTeam,
    required this.finished,
  });

  final PremierLeagueMatchDetails? details;
  final TeamModel? homeTeam;
  final TeamModel? awayTeam;
  final bool finished;

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  Map<int, String> _playerNames = const {};

  @override
  void initState() {
    super.initState();
    _playerNames = _buildPlayerNames();
  }

  @override
  void didUpdateWidget(covariant TimelineView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.details != widget.details) {
      _playerNames = _buildPlayerNames();
    }
  }

  Map<int, String> _buildPlayerNames() {
    final names = <int, String>{};
    for (final player in [
      ...?widget.details?.homeLineup?.players,
      ...?widget.details?.awayLineup?.players,
    ]) {
      final id = player.id;
      final name = player.name;
      if (id != null && name != null && name.isNotEmpty) {
        names[id] = name;
      }
    }
    return names;
  }

  String _name(int? id) {
    if (id == null) return 'Player unavailable';
    return _playerNames[id] ?? 'Player unavailable';
  }

  _EventSide _sideOf(MatchEvent event) {
    final homeId = widget.details?.homeTeam?.id;
    final awayId = widget.details?.awayTeam?.id;
    if (event.teamId == null || homeId == null || awayId == null) {
      return _EventSide.unknown;
    }
    if (event.teamId == homeId) return _EventSide.home;
    if (event.teamId == awayId) return _EventSide.away;
    return _EventSide.unknown;
  }

  bool _isFirstHalf(MatchEvent event) {
    final period = event.period?.toLowerCase() ?? '';
    if (period.contains('first')) return true;
    if (period.contains('second')) return false;
    final minute = event.minute;
    return minute != null && minute <= 45;
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.details?.events ?? const <MatchEvent>[];
    if (events.isEmpty) {
      return const SectionEmptyState(
        icon: Icons.timeline_rounded,
        title: 'Match timeline unavailable',
        message: 'Verified event data is not available for this fixture.',
      );
    }

    final firstHalf = <MatchEvent>[];
    final secondHalf = <MatchEvent>[];
    final unknownPeriod = <MatchEvent>[];
    for (final event in events) {
      if (event.minute == null && event.period == null) {
        unknownPeriod.add(event);
      } else if (_isFirstHalf(event)) {
        firstHalf.add(event);
      } else {
        secondHalf.add(event);
      }
    }

    final children = <Widget>[
      _TeamHeader(homeTeam: widget.homeTeam, awayTeam: widget.awayTeam),
    ];
    if (firstHalf.isNotEmpty) {
      children.add(const _PeriodHeader(label: 'FIRST HALF'));
      children.addAll(firstHalf.map((event) => _rowFor(event)));
    }
    if (firstHalf.isNotEmpty && secondHalf.isNotEmpty) {
      children.add(const _SplitDivider(label: 'HALF TIME'));
    }
    if (secondHalf.isNotEmpty) {
      children.add(const _PeriodHeader(label: 'SECOND HALF'));
      children.addAll(secondHalf.map((event) => _rowFor(event)));
    }
    if (unknownPeriod.isNotEmpty) {
      children.add(const _PeriodHeader(label: 'MATCH EVENTS'));
      children.addAll(unknownPeriod.map((event) => _rowFor(event)));
    }
    if (widget.finished) {
      children.add(const _SplitDivider(label: 'FULL TIME'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoSided = constraints.maxWidth >= 340;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final child in children)
              if (child is _EventRow)
                _EventRow(
                  event: child.event,
                  side: child.side,
                  playerName: child.playerName,
                  twoSided: twoSided,
                )
              else
                child,
          ],
        );
      },
    );
  }

  Widget _rowFor(MatchEvent event) => _EventRow(
    event: event,
    side: _sideOf(event),
    playerName: _name,
    twoSided: true,
  );
}

class _TeamHeader extends StatelessWidget {
  const _TeamHeader({required this.homeTeam, required this.awayTeam});

  final TeamModel? homeTeam;
  final TeamModel? awayTeam;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: MatchDetailsStyle.spaceSm),
    child: Row(
      children: [
        Expanded(
          child: _TeamTag(
            team: homeTeam,
            side: 'H',
            alignment: CrossAxisAlignment.start,
          ),
        ),
        const SizedBox(width: MatchDetailsStyle.spaceSm),
        Expanded(
          child: _TeamTag(
            team: awayTeam,
            side: 'A',
            alignment: CrossAxisAlignment.end,
          ),
        ),
      ],
    ),
  );
}

class _TeamTag extends StatelessWidget {
  const _TeamTag({
    required this.team,
    required this.side,
    required this.alignment,
  });

  final TeamModel? team;
  final String side;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final name = team?.name.trim();
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          (name == null || name.isEmpty) ? 'Team unavailable' : name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign:
              alignment == CrossAxisAlignment.end
                  ? TextAlign.end
                  : TextAlign.start,
          style: TextStyle(
            color:
                side == 'H'
                    ? context.appColors.matchHome
                    : context.appColors.matchAway,
            fontSize: MatchDetailsStyle.microSize,
            fontWeight: FontWeight.w800,
            letterSpacing: .1,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          side == 'H' ? 'HOME' : 'AWAY',
          style: TextStyle(
            color: context.appColors.lineupTextSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: .6,
          ),
        ),
      ],
    );
  }
}

class _PeriodHeader extends StatelessWidget {
  const _PeriodHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 10, 0, 6),
    child: Text(
      label,
      style: TextStyle(
        color: context.appColors.lineupTextSecondary,
        fontSize: MatchDetailsStyle.microSize,
        fontWeight: FontWeight.w800,
        letterSpacing: .8,
      ),
    ),
  );
}

class _SplitDivider extends StatelessWidget {
  const _SplitDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Expanded(child: Divider(color: context.appColors.lineupControl)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: TextStyle(
              color: context.appColors.lineupTextSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: .7,
            ),
          ),
        ),
        Expanded(child: Divider(color: context.appColors.lineupControl)),
      ],
    ),
  );
}

class _EventRow extends StatelessWidget {
  const _EventRow({
    required this.event,
    required this.side,
    required this.playerName,
    required this.twoSided,
  });

  final MatchEvent event;
  final _EventSide side;
  final String Function(int?) playerName;
  final bool twoSided;

  bool get _isGoal => event.kind == 'goal';
  bool get _isCard => event.kind == 'card';
  bool get _isSub => event.kind == 'substitution';
  bool get _isOwnGoal =>
      event.kind == 'goal' && (event.goalType ?? '').toLowerCase() == 'own';
  bool get _isRedCard => (event.cardType ?? '').toLowerCase().contains('red');

  Color _sideColor(BuildContext context) => switch (side) {
    _EventSide.home => context.appColors.matchHome,
    _EventSide.away => context.appColors.matchAway,
    _EventSide.unknown => context.appColors.matchDraw,
  };

  String get _minute => event.minute == null ? '—' : "${event.minute}'";

  @override
  Widget build(BuildContext context) {
    if (!twoSided) return _singleSided(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child:
                side == _EventSide.home
                    ? _content(context, alignEnd: true)
                    : const SizedBox.shrink(),
          ),
          _MinuteRail(minute: _minute, color: _sideColor(context)),
          Expanded(
            child:
                side == _EventSide.away
                    ? _content(context, alignEnd: false)
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _singleSided(BuildContext context) {
    final color = _sideColor(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 38,
            child: Text(
              _minute,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: context.appColors.lineupTextSecondary,
                fontSize: MatchDetailsStyle.microSize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 3,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: _content(context, alignEnd: false)),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, {required bool alignEnd}) {
    final color = _sideColor(context);
    return Semantics(
      label: _semanticLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color:
              _isGoal
                  ? color.withValues(alpha: .10)
                  : context.appColors.lineupPanel.withValues(alpha: .65),
          borderRadius: BorderRadius.circular(10),
          border:
              _isGoal
                  ? Border.all(color: color.withValues(alpha: .28))
                  : Border.all(
                    color: context.appColors.lineupControl.withValues(
                      alpha: .6,
                    ),
                  ),
        ),
        child: Column(
          crossAxisAlignment:
              alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!alignEnd) ...[
                  _EventIcon(event: event, sideColor: color, red: _isRedCard),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    _headline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: alignEnd ? TextAlign.end : TextAlign.start,
                    style: TextStyle(
                      color: context.appColors.lineupText,
                      fontSize:
                          _isGoal
                              ? MatchDetailsStyle.bodyStrongSize
                              : MatchDetailsStyle.bodySize,
                      fontWeight: _isGoal ? FontWeight.w800 : FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ),
                if (alignEnd) ...[
                  const SizedBox(width: 6),
                  _EventIcon(event: event, sideColor: color, red: _isRedCard),
                ],
              ],
            ),
            if (_secondary != null) ...[
              const SizedBox(height: 3),
              Text(
                _secondary!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: alignEnd ? TextAlign.end : TextAlign.start,
                style: TextStyle(
                  color: context.appColors.lineupTextSecondary,
                  fontSize: 10,
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String get _headline => switch (event.kind) {
    'goal' => _isOwnGoal ? 'Own goal' : 'Goal',
    'card' => '${event.cardType ?? 'Card'} card',
    'substitution' => 'Substitution',
    _ => 'Match event',
  };

  String? get _secondary {
    if (_isSub) {
      return 'On: ${playerName(event.playerOnId)}\nOff: ${playerName(event.playerOffId)}';
    }
    if (_isGoal) {
      final scorer = playerName(event.playerId);
      final assistId = event.assistPlayerId;
      if (assistId == null) return scorer;
      return '$scorer · assist ${playerName(assistId)}';
    }
    if (_isCard) return playerName(event.playerId);
    return null;
  }

  String get _semanticLabel {
    final parts = <String>[
      _minute,
      _headline,
      if (_secondary != null) _secondary!.replaceAll('\n', ', '),
    ];
    return parts.join(', ');
  }
}

class _MinuteRail extends StatelessWidget {
  const _MinuteRail({required this.minute, required this.color});

  final String minute;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 38,
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .14),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            minute,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: MatchDetailsStyle.microSize,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        Container(width: 1, height: 16, color: context.appColors.lineupControl),
      ],
    ),
  );
}

class _EventIcon extends StatelessWidget {
  const _EventIcon({
    required this.event,
    required this.sideColor,
    required this.red,
  });

  final MatchEvent event;
  final Color sideColor;
  final bool red;

  @override
  Widget build(BuildContext context) {
    if (event.kind == 'goal') {
      return Icon(Icons.sports_soccer_rounded, size: 14, color: sideColor);
    }
    if (event.kind == 'card') {
      return Container(
        width: 9,
        height: 12,
        decoration: BoxDecoration(
          color: red ? const Color(0xFFE5484D) : const Color(0xFFE8B931),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }
    if (event.kind == 'substitution') {
      return Icon(
        Icons.swap_vert_rounded,
        size: 14,
        color: context.appColors.lineupTextSecondary,
      );
    }
    return Icon(
      Icons.circle_outlined,
      size: 11,
      color: context.appColors.lineupTextSecondary,
    );
  }
}
