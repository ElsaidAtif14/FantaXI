import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/history/data/models/event_history.dart';
import 'package:flutter/material.dart';

class HistoryQuickStats extends StatelessWidget {
  const HistoryQuickStats({super.key, required this.event});

  final EventHistory? event;

  @override
  Widget build(BuildContext context) {
    final selectedEvent = event;

    return Row(
      children: [
        Expanded(
          child: _QuickStat(
            label: 'TRANSFERS',
            value: selectedEvent?.transfers.toString() ?? '-',
            footnote: selectedEvent == null
                ? 'Selected GW'
                : selectedEvent.transfersCost > 0
                    ? '-${selectedEvent.transfersCost} hit pts'
                    : 'No hit points',
            valueColor: context.appColors.lineupText,
            icon: Icons.swap_horiz_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickStat(
            label: 'SQUAD VALUE',
            value: selectedEvent == null
                ? '-'
                : '\u00A3${selectedEvent.teamValue.toStringAsFixed(1)}m',
            footnote: selectedEvent == null
                ? 'Selected GW'
                : '\u00A3${selectedEvent.bank.toStringAsFixed(1)}m in bank',
            valueColor: context.appColors.lineupMint,
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickStat(
            label: 'BENCH PTS',
            value: selectedEvent?.pointsOnBench.toString() ?? '-',
            footnote: selectedEvent == null ? 'Selected GW' : 'Unclaimed',
            valueColor: const Color(0xFFFFB4AB),
            icon: Icons.event_seat_outlined,
          ),
        ),
      ],
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.label,
    required this.value,
    required this.footnote,
    required this.valueColor,
    required this.icon,
  });

  final String label;
  final String value;
  final String footnote;
  final Color valueColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 82),
    padding: const EdgeInsets.all(9),
    decoration: BoxDecoration(
      color: context.appColors.lineupSurface,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(icon, color: context.appColors.lineupTextSecondary, size: 12),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:  TextStyle(
                  color: context.appColors.lineupTextSecondary,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  letterSpacing: .2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: valueColor,
            fontSize: 19,
            height: 1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          footnote,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:  TextStyle(
            color: context.appColors.lineupTextSecondary,
            fontSize: 8,
          ),
        ),
      ],
    ),
  );
}
