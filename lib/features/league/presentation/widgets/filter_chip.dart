
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/league/presentation/widgets/league_view_body.dart';
import 'package:flutter/material.dart';

class FilterChip extends StatelessWidget {
  const FilterChip({super.key, 
    required this.title,
    required this.value,
    required this.selected,
    required this.onSelected,
    this.count,
  });

  final String title;
  final LeagueFilter value;
  final LeagueFilter selected;
  final ValueChanged<LeagueFilter> onSelected;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final active = selected == value;
    final label = count == null ? title : '$title ($count)';
    return Material(
      color:
          active
              ? context.appColors.primary
              : context.appColors.leagueBadgeBackground,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: () => onSelected(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color:
                  active
                      ? context.appColors.primary
                      : context.appColors.leagueBadgeBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color:
                  active
                      ? context.appColors.leagueWhite
                      : context.appColors.leagueBadgeText,
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}