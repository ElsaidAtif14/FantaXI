import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/matches/presentation/widgets/match_details_style.dart';
import 'package:flutter/material.dart';

enum MatchStatusKind { fullTime, live, upcoming }

/// Compact, non-duplicated status indicator used by the scoreboard.
class MatchStatusPill extends StatelessWidget {
  const MatchStatusPill({super.key, required this.kind, this.minute});

  final MatchStatusKind kind;

  /// Live minute label such as `55'` or `90+'`.
  final String? minute;

  String get _label => switch (kind) {
    MatchStatusKind.fullTime => 'FULL TIME',
    MatchStatusKind.live =>
      (minute == null || minute!.isEmpty) ? 'LIVE' : 'LIVE · $minute',
    MatchStatusKind.upcoming => 'UPCOMING',
  };

  Color _color(BuildContext context) => switch (kind) {
    MatchStatusKind.fullTime => context.appColors.lineupTextSecondary,
    MatchStatusKind.live => context.appColors.matchLive,
    MatchStatusKind.upcoming => context.appColors.lineupLavender,
  };

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Semantics(
      label: _label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .16),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: color.withValues(alpha: .32)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (kind == MatchStatusKind.live) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              _label,
              style: TextStyle(
                color: color,
                fontSize: MatchDetailsStyle.microSize,
                fontWeight: FontWeight.w800,
                letterSpacing: .5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
