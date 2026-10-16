

import 'package:fantasy/features/league/data/models/league_response_model.dart';
import 'package:fantasy/features/league/presentation/widgets/filter_chip.dart';
import 'package:fantasy/features/league/presentation/widgets/league_view_body.dart';
import 'package:flutter/material.dart' hide FilterChip;

class FilterChips extends StatelessWidget {
  const FilterChips({super.key, 
    required this.selected,
    required this.standings,
    required this.current,
    required this.onSelected,
  });

  final LeagueFilter selected;
  final List<LeagueStanding> standings;
  final LeagueStanding? current;
  final ValueChanged<LeagueFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final nearCount = current == null
        ? 0
        : standings
            .where((item) => (item.rank - current!.rank).abs() <= 5)
            .length;
    final rivalCount = standings.length > (current == null ? 0 : 1)
        ? (standings.length - (current == null ? 0 : 1))
            .clamp(0, 4)
            .toInt()
        : 0;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            title: 'All',
            value: LeagueFilter.all,
            selected: selected,
            onSelected: onSelected,
          ),
          const SizedBox(width: 7),
          FilterChip(
            title: 'Top 10',
            value: LeagueFilter.topTen,
            selected: selected,
            onSelected: onSelected,
          ),
          const SizedBox(width: 7),
          FilterChip(
            title: current == null ? 'Near Me' : 'Near Me (±5)',
            value: LeagueFilter.nearMe,
            selected: selected,
            onSelected: onSelected,
            count: current == null ? null : nearCount,
          ),
          const SizedBox(width: 7),
          FilterChip(
            title: 'Rivals',
            value: LeagueFilter.rivals,
            selected: selected,
            onSelected: onSelected,
            count: rivalCount,
          ),
        ],
      ),
    );
  }
}
