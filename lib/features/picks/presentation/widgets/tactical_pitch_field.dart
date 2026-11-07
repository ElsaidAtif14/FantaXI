import 'package:fantasy/features/bootstrap/data/models/bootstrap_model.dart';
import 'package:fantasy/features/live/data/models/element_live_model.dart';
import 'package:fantasy/features/picks/data/models/gameweek_picks_model.dart';
import 'package:fantasy/features/picks/presentation/widgets/player_pitch_icon.dart';
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

/// Renders the starting XI by position over the tactical field markings.
class TacticalPitchField extends StatelessWidget {
  const TacticalPitchField({
    super.key,
    required this.picks,
    required this.bootstrap,
    this.liveData,
  });

  final List<TeamPick> picks;
  final BootstrapModel bootstrap;
  final LiveGWModel? liveData;

  @override
  Widget build(BuildContext context) {
    final groups = <int, List<TeamPick>>{
      for (var type = 1; type <= 4; type++)
        type: picks.where((pick) => pick.elementType == type).toList(),
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient:  LinearGradient(
            colors: [
              context.appColors.lineupPitchTop,
              context.appColors.lineupPitchMiddle,
              context.appColors.lineupPitchBottom,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(
            color: context.appColors.lineupPitchLine.withValues(alpha: .7),
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _PitchPainter(context.appColors.lineupPitchLine),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (picks.isEmpty)
                     Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Text(
                        'No starting XI is available',
                        style: TextStyle(
                          color: context.appColors.lineupTextSecondary,
                          fontSize: 10,
                        ),
                      ),
                    )
                  else
                    for (var position = 1; position <= 4; position++)
                      if (groups[position]!.isNotEmpty) ...[
                        if (position > 1) const SizedBox(height: 8),
                        _PositionRow(
                          position: position,
                          picks: groups[position]!,
                          bootstrap: bootstrap,
                          liveData: liveData,
                        ),
                      ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PositionRow extends StatelessWidget {
  const _PositionRow({
    required this.position,
    required this.picks,
    required this.bootstrap,
    required this.liveData,
  });

  final int position;
  final List<TeamPick> picks;
  final BootstrapModel bootstrap;
  final LiveGWModel? liveData;

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (position) {
      1 => ('KEEPER', Icons.sports_soccer_rounded),
      2 => ('DEFENCE (${picks.length})', Icons.shield_outlined),
      3 => ('MIDFIELD (${picks.length})', Icons.bolt_rounded),
      _ => ('ATTACK (${picks.length})', Icons.track_changes_rounded),
    };
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: context.appColors.lineupMint, size: 10),
            const SizedBox(width: 4),
            Text(
              label,
              style:  TextStyle(
                color: context.appColors.lineupTextSecondary,
                fontSize: 7,
                fontWeight: FontWeight.w700,
                letterSpacing: .55,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 3,
          runSpacing: 4,
          children: [
            for (final pick in picks)
              Builder(
                builder: (context) {
                  final player = bootstrap.getPlayer(pick.element);
                  if (player == null) return const SizedBox.shrink();
                  return PlayerPitchIcon(
                    player: player,
                    pick: pick,
                    liveData: liveData,
                    bootstrap: bootstrap,
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _PitchPainter extends CustomPainter {
  const _PitchPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color.withValues(alpha: .48)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;
    final rect = Rect.fromLTWH(8, 8, size.width - 16, size.height - 16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      paint,
    );
    canvas.drawLine(
      Offset(8, size.height / 2),
      Offset(size.width - 8, size.height / 2),
      paint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * .13,
      paint,
    );

    final boxWidth = size.width * .42;
    final boxHeight = size.height * .09;
    canvas.drawRect(
      Rect.fromLTWH((size.width - boxWidth) / 2, 8, boxWidth, boxHeight),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - boxWidth) / 2,
        size.height - 8 - boxHeight,
        boxWidth,
        boxHeight,
      ),
      paint,
    );
    final goalWidth = size.width * .2;
    const goalHeight = 5.0;
    canvas.drawRect(
      Rect.fromLTWH((size.width - goalWidth) / 2, 8, goalWidth, goalHeight),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - goalWidth) / 2,
        size.height - 8 - goalHeight,
        goalWidth,
        goalHeight,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PitchPainter oldDelegate) =>
      color != oldDelegate.color;
}
