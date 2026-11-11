import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/matches/presentation/widgets/match_details_style.dart';
import 'package:flutter/material.dart';

/// Consistent section title used across the Match Details screen.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(
      MatchDetailsStyle.gutter,
      MatchDetailsStyle.sectionGap,
      MatchDetailsStyle.gutter,
      0,
    ),
  });

  final String title;
  final String? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final trailingText = trailing;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                color: context.appColors.lineupTextSecondary,
                fontSize: MatchDetailsStyle.microSize,
                fontWeight: FontWeight.w700,
                letterSpacing: .8,
              ),
            ),
          ),
          if (trailingText != null)
            Text(
              trailingText,
              style: TextStyle(
                color: context.appColors.lineupTextSecondary.withValues(
                  alpha: .8,
                ),
                fontSize: MatchDetailsStyle.microSize,
                fontWeight: FontWeight.w600,
                letterSpacing: .2,
              ),
            ),
        ],
      ),
    );
  }
}
