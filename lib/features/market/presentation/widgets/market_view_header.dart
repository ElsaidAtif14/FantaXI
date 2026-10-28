import 'package:fantasy/core/theme/app_colors.dart';
import 'package:fantasy/features/market/presentation/widgets/market_sort.dart';
import 'package:flutter/material.dart';

class MarketViewHeader extends StatelessWidget {
  const MarketViewHeader({
    required this.bank,
    required this.gameweek,
    required this.sort,
    required this.onSort,
    super.key,
  });

  final double? bank;
  final int? gameweek;
  final MarketSort sort;
  final ValueChanged<MarketSort> onSort;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  color: AppColors.marketMint.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.sports_soccer_rounded,
                  color: AppColors.marketMint,
                  size: 16,
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Market',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              PopupMenuButton<MarketSort>(
                tooltip: 'Sort players',
                initialValue: sort,
                onSelected: onSort,
                icon: const Icon(
                  Icons.settings_outlined,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                itemBuilder:
                    (_) => MarketSort.values
                        .map(
                          (value) => PopupMenuItem(
                            value: value,
                            child: Text(value.label),
                          ),
                        )
                        .toList(),
              ),
              const CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.marketLavender,
                child: Icon(
                  Icons.person,
                  size: 17,
                  color: AppColors.marketBackground,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.marketMint,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.marketMint,
                      blurRadius: 7,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'GAMEWEEK ${gameweek ?? '—'} MARKET OPEN',
                style: const TextStyle(
                  color: AppColors.marketText,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .45,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.marketControl,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 11,
                      color: AppColors.marketMint,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'BANK',
                      style: TextStyle(
                        color: AppColors.marketText,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      bank == null ? '—' : '£${bank!.toStringAsFixed(1)}m',
                      style: const TextStyle(
                        color: AppColors.marketMint,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
