import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class LeaguesHubMovementChip extends StatelessWidget {
  const LeaguesHubMovementChip({required this.movement, super.key});

  final int movement;

  @override
  Widget build(BuildContext context) {
    final unchanged = movement == 0;
    final isUp = movement > 0;
    final color =
        unchanged
            ? context.appColors.lineupTextSecondary
            : isUp
            ? context.appColors.lineupMint
            : const Color(0xFFFF6B78);
    final icon =
        unchanged
            ? Icons.remove_rounded
            : !isUp
            ? Icons.keyboard_double_arrow_down
            : movement.abs() >= 1000
            ? Icons.keyboard_double_arrow_up
            : Icons.arrow_upward_rounded;
    final value = _formatMovement(movement.abs());
    final label =
        movement.abs() >= 1000
            ? value
            : unchanged
            ? 'No change'
            : isUp
            ? '+$value Pos'
            : value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatMovement(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return '$value';
  }
}
