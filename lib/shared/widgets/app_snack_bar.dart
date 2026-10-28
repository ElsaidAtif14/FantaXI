import 'package:fantasy/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum AppSnackBarType { info, success, warning, error }

class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    AppSnackBarType type = AppSnackBarType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    final color = switch (type) {
      AppSnackBarType.info => AppColors.electricBlue,
      AppSnackBarType.success => AppColors.secondary,
      AppSnackBarType.warning => AppColors.warmOrange,
      AppSnackBarType.error => AppColors.rankDown,
    };
    final icon = switch (type) {
      AppSnackBarType.info => Icons.info_outline,
      AppSnackBarType.success => Icons.check_circle_outline,
      AppSnackBarType.warning => Icons.warning_amber_rounded,
      AppSnackBarType.error => Icons.error_outline,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surface,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.outline),
        ),
      ),
    );
  }
}
