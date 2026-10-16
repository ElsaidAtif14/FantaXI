import 'package:fantasy/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ErrorMessageView extends StatelessWidget {
  const ErrorMessageView({
    super.key,
    this.title = 'Could not load your manager',
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.lineupLavender, size: 34),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.lineupText,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.lineupTextSecondary),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.lineupPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: onAction,
            child: Text(actionLabel),
          ),
        ],
      ),
    ),
  );
}
