import 'package:fantasy/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class MarketQuickFilters extends StatelessWidget {
  const MarketQuickFilters({super.key});

  @override
  Widget build(BuildContext context) {
    const filters = [
      ('Price ≤ £8.0m', Icons.payments_outlined),
      ('Top Form', Icons.local_fire_department_outlined),
      ('Price Risers', Icons.trending_up),
      ('Most Selected', Icons.people_outline),
    ];

    return SizedBox(
      height: 30,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final label = filters[index].$1;
          final icon = filters[index].$2;
          final isPrimary = index == 0;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.marketControl,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 11,
                  color:
                      isPrimary ? AppColors.marketMint : AppColors.marketLavender,
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    color:
                        isPrimary ? AppColors.marketMint : AppColors.marketText,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
