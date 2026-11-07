import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class MarketPositionSelector extends StatelessWidget {
  const MarketPositionSelector({
    required this.selected,
    required this.counts,
    required this.onSelected,
    super.key,
  });

  final int? selected;
  final Map<int?, int> counts;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    const values = <int?>[null, 1, 2, 3, 4];
    const labels = ['ALL', 'GKP', 'DEF', 'MID', 'FWD'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.appColors.marketBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelected(values[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color:
                        selected == values[i]
                            ? context.appColors.marketLavender
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow:
                        selected == values[i]
                            ? [
                              BoxShadow(
                                color: context.appColors.marketLavender.withValues(
                                  alpha: .35,
                                ),
                                blurRadius: 8,
                              ),
                            ]
                            : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        labels[i],
                        style: TextStyle(
                          color:
                              selected == values[i]
                                  ? context.appColors.marketSelectedText
                                  : context.appColors.marketText,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (i > 0) ...[
                        const SizedBox(width: 3),
                        Text(
                          '${counts[values[i]] ?? 0}',
                          style: TextStyle(
                            color:
                                selected == values[i]
                                    ? context.appColors.marketSelectedText
                                    : context.appColors.marketText,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
