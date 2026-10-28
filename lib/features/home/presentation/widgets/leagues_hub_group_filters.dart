import 'package:fantasy/core/theme/app_colors.dart';
import 'package:fantasy/features/home/presentation/widgets/leagues_hub_models.dart';
import 'package:flutter/material.dart';

class LeaguesHubGroupFilters extends StatelessWidget {
  const LeaguesHubGroupFilters({
    required this.selected,
    required this.allCount,
    required this.globalCount,
    required this.privateCount,
    required this.onSelected,
    super.key,
  });

  final LeaguesHubFilterGroup selected;
  final int allCount;
  final int globalCount;
  final int privateCount;
  final ValueChanged<LeaguesHubFilterGroup> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        _LeaguesHubGroupChip(
          label: 'All Leagues ($allCount)',
          group: LeaguesHubFilterGroup.all,
          selected: selected,
          onSelected: onSelected,
        ),
        const SizedBox(width: 8),
        _LeaguesHubGroupChip(
          label: 'Global & Official ($globalCount)',
          group: LeaguesHubFilterGroup.global,
          selected: selected,
          onSelected: onSelected,
        ),
        const SizedBox(width: 8),
        _LeaguesHubGroupChip(
          label: 'Private Mini ($privateCount)',
          group: LeaguesHubFilterGroup.private,
          selected: selected,
          onSelected: onSelected,
        ),
      ],
    ),
  );
}

class _LeaguesHubGroupChip extends StatelessWidget {
  const _LeaguesHubGroupChip({
    required this.label,
    required this.group,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final LeaguesHubFilterGroup group;
  final LeaguesHubFilterGroup selected;
  final ValueChanged<LeaguesHubFilterGroup> onSelected;

  @override
  Widget build(BuildContext context) {
    final active = group == selected;
    return Material(
      color: active ? const Color(0xFF2B1E4A) : AppColors.lineupControl,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: () => onSelected(group),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color:
                  active
                      ? AppColors.lineupLavender
                      : AppColors.lineupTextSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
