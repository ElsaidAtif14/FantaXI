import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/manager/data/models/fantasy_manager_model.dart';
import 'package:flutter/material.dart';

/// Two equal-height stat cards side by side.
///
/// Layout note (root cause of two historical defects, measured in tests):
/// - Tile height from `childAspectRatio` is independent of content and clipped
///   card content at narrow widths / large text scales.
/// - A shrinkWrap [GridView] is a *scrollable*; under a [Scaffold] with
///   `extendBody: true` it reserved the exposed viewport bottom inset (dock
///   height) as empty trailing space inside its own box, leaving a large gap
///   directly below the two cards.
/// The [IntrinsicHeight] + stretch [Row] keeps equal card heights derived
/// from real content (the [Spacer]s absorb the slack) and is not scrollable,
/// so neither defect can occur.
class HomeStatsGrid extends StatelessWidget {
  const HomeStatsGrid({super.key, required this.manager});

  final FantasyManagerModel manager;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 360;
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Expanded(child: _RankCard(manager: manager, compact: compact)),
            Expanded(child: _ValueCard(manager: manager, compact: compact)),
          ],
        ),
      );
    },
  );
}

class _RankCard extends StatelessWidget {
  const _RankCard({required this.manager, required this.compact});
  final FantasyManagerModel manager;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _IconBadge(
                icon: Icons.military_tech_rounded,
                color: context.appColors.primaryLight,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'GLOBAL POS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: context.appColors.textSecondary,
                    letterSpacing: .6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    manager.rankFormatted,
                    style: textTheme.displayLarge?.copyWith(
                      fontSize: compact ? 27 : 34,
                      height: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _RankIndicator(
                color: context.appColors.primaryLight,
                size: compact ? 48 : 58,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            'Overall rank',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.sports_soccer_rounded,
                size: 14,
                color: context.appColors.homeMint,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${_formatPoints(manager.eventPoints)} pts this gameweek',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: context.appColors.homeMint,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({required this.manager, required this.compact});
  final FantasyManagerModel manager;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconBadge(
                icon: Icons.account_balance_wallet_rounded,
                color: context.appColors.homeMint,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'SQUAD VALUE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: context.appColors.textSecondary,
                    letterSpacing: .6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '\u00A3${manager.teamValue.toStringAsFixed(1)}m',
                    style: textTheme.displayLarge?.copyWith(
                      fontSize: compact ? 25 : 32,
                      height: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: compact ? 38 : 52,
                height: 32,
                child: CustomPaint(
                  painter: _SparklinePainter(context.appColors.homeMint),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Bank: \u00A3${manager.bank.toStringAsFixed(1)}m',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              color: context.appColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            'Total points: ${_formatPoints(manager.totalPoints)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelMedium?.copyWith(
              color: context.appColors.homeMint,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.appColors.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: context.appColors.outline.withValues(alpha: .55),
      ),
    ),
    child: child,
  );
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .15),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: color, size: 19),
  );
}

class _RankIndicator extends StatelessWidget {
  const _RankIndicator({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: .7), width: 5),
        color: color.withValues(alpha: .08),
      ),
      child: Icon(Icons.military_tech_rounded, color: color, size: size * .44),
    ),
  );
}

class _SparklinePainter extends CustomPainter {
  const _SparklinePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path =
        Path()
          ..moveTo(0, size.height * .78)
          ..lineTo(size.width * .25, size.height * .62)
          ..lineTo(size.width * .52, size.height * .7)
          ..lineTo(size.width * .75, size.height * .35)
          ..lineTo(size.width, size.height * .18);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      color != oldDelegate.color;
}

String _formatPoints(int points) => points.abs().toString().replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (_) => ',',
);
