import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/matches/presentation/widgets/match_details_style.dart';
import 'package:flutter/material.dart';

/// Honest, consistent empty state shared by every Match Details tab.
class SectionEmptyState extends StatelessWidget {
  const SectionEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;
    final action = onAction;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: context.appColors.lineupPanel,
        borderRadius: BorderRadius.circular(MatchDetailsStyle.panelRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: context.appColors.lineupControl,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: context.appColors.lineupTextSecondary,
            ),
          ),
          const SizedBox(height: MatchDetailsStyle.spaceMd),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.appColors.lineupText,
              fontSize: MatchDetailsStyle.bodyStrongSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: MatchDetailsStyle.spaceXs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.appColors.lineupTextSecondary,
              fontSize: MatchDetailsStyle.labelSize + 1,
              height: 1.45,
            ),
          ),
          if (label != null && action != null) ...[
            const SizedBox(height: MatchDetailsStyle.spaceMd),
            TextButton(onPressed: action, child: Text(label)),
          ],
        ],
      ),
    );
  }
}
