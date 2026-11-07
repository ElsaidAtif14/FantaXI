import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class FormationActions extends StatelessWidget {
  const FormationActions({
    super.key,
    required this.defenders,
    required this.midfielders,
    required this.forwards,
    required this.played,
    required this.startingCount,
  });

  final int defenders;
  final int midfielders;
  final int forwards;
  final int startingCount;
  final int? played;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Flexible(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: context.appColors.lineupPurple.withValues(alpha: .2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$defenders-$midfielders-$forwards FORMATION',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:  TextStyle(
              color: context.appColors.lineupLavender,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: .35,
            ),
          ),
        ),
      ),
      const SizedBox(width: 6),
      Text(
        '${played ?? '—'} / $startingCount Played',
        style:  TextStyle(
          color: context.appColors.lineupTextSecondary,
          fontSize: 8,
        ),
      ),
      const Spacer(),
      const _UnavailableAction(
        icon: Icons.query_stats_rounded,
        label: 'Stats',
        tooltip: 'Stats view is not available yet',
      ),
      const SizedBox(width: 5),
      const _UnavailableAction(
        icon: Icons.share_outlined,
        label: '',
        tooltip: 'Sharing is not available yet',
      ),
    ],
  );
}

class _UnavailableAction extends StatelessWidget {
  const _UnavailableAction({
    required this.icon,
    required this.label,
    required this.tooltip,
  });

  final IconData icon;
  final String label;
  final String tooltip;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Container(
      height: 28,
      padding: EdgeInsets.symmetric(horizontal: label.isEmpty ? 6 : 8),
      decoration: BoxDecoration(
        color: context.appColors.lineupControl.withValues(alpha: .8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: context.appColors.lineupTextSecondary.withValues(alpha: .55),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: context.appColors.lineupTextSecondary.withValues(alpha: .55),
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
