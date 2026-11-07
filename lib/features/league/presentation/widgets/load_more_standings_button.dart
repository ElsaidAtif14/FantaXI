import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class LoadMoreStandingsButton extends StatelessWidget {
  const LoadMoreStandingsButton({
    super.key,
    required this.hasError,
    required this.onPressed,
  });

  final bool hasError;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 12),
    child: OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        hasError ? Icons.refresh_rounded : Icons.expand_more_rounded,
        size: 18,
      ),
      label: Text(hasError ? 'Retry loading standings' : 'Load more standings'),
      style: OutlinedButton.styleFrom(
        foregroundColor: context.appColors.leagueText,
        side: BorderSide(color: context.appColors.leagueCardBorder),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    ),
  );
}
