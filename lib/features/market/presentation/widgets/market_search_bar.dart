import 'package:fantasy/features/market/presentation/widgets/market_sort.dart';
import 'package:fantasy/features/market/presentation/widgets/market_square_button.dart';
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class MarketSearchBar extends StatelessWidget {
  const MarketSearchBar({
    required this.controller,
    required this.onSearchChanged,
    required this.onSortPressed,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onSearchChanged;
  final VoidCallback onSortPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (_) => onSearchChanged(),
              textInputAction: TextInputAction.search,
              style:  TextStyle(
                color: context.appColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Search players, clubs...',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon:
                    controller.text.isEmpty
                        ? null
                        : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            controller.clear();
                            onSearchChanged();
                          },
                          icon: const Icon(Icons.close, size: 18),
                        ),
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
                filled: true,
                fillColor: context.appColors.marketInput,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.appColors.marketInput),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:  BorderSide(color: context.appColors.marketLavender),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          MarketSquareButton(
            icon: Icons.tune_rounded,
            tooltip: 'Sort players',
            onPressed: onSortPressed,
          ),
        ],
      ),
    );
  }
}

class MarketSortSheet extends StatelessWidget {
  const MarketSortSheet({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final MarketSort selected;
  final ValueChanged<MarketSort> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in MarketSort.values)
            ListTile(
              title: Text(option.label),
              trailing:
                  selected == option
                      ?  Icon(Icons.check, color: context.appColors.marketLavender)
                      : null,
              onTap: () {
                onSelected(option);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}
