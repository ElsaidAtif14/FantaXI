import 'package:fantasy/features/market/presentation/widgets/market_sort.dart';
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

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
