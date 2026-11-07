import 'package:fantasy/features/market/presentation/widgets/market_sort.dart';
import 'package:fantasy/core/theme/app_theme_colors.dart';
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
                  color: context.appColors.marketMint.withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:  Icon(
                  Icons.sports_soccer_rounded,
                  color: context.appColors.marketMint,
                  size: 16,
                ),
              ),
              const SizedBox(width: 9),
               Expanded(
                child: Text(
                  'Market',
                  style: TextStyle(
                    color: context.appColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              PopupMenuButton<MarketSort>(
                tooltip: 'Sort players',
                initialValue: sort,
                onSelected: onSort,
                icon:  Icon(
                  Icons.settings_outlined,
                  size: 20,
                  color: context.appColors.textSecondary,
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
               CircleAvatar(
                radius: 14,
                backgroundColor: context.appColors.marketLavender,
                child: Icon(
                  Icons.person,
                  size: 17,
                  color: context.appColors.marketBackground,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration:  BoxDecoration(
                  color: context.appColors.marketMint,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: context.appColors.marketMint,
                      blurRadius: 7,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'GAMEWEEK ${gameweek ?? '—'} MARKET OPEN',
                style:  TextStyle(
                  color: context.appColors.marketText,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .45,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.appColors.marketControl,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 11,
                      color: context.appColors.marketMint,
                    ),
                    const SizedBox(width: 4),
                     Text(
                      'BANK',
                      style: TextStyle(
                        color: context.appColors.marketText,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      bank == null ? '—' : '£${bank!.toStringAsFixed(1)}m',
                      style:  TextStyle(
                        color: context.appColors.marketMint,
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
