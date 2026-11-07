import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class HomeFeedback extends StatelessWidget {
  const HomeFeedback({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: context.appColors.lineupLavender.withValues(
                    alpha: .12,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: context.appColors.lineupLavender,
                  size: 23,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.appColors.lineupText,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.appColors.lineupTextSecondary,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              if (onAction != null)
                FilledButton(
                  onPressed: onAction,
                  style: FilledButton.styleFrom(
                    backgroundColor: context.appColors.lineupPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 11,
                    ),
                  ),
                  child: Text(actionLabel),
                ),
              if (onSecondaryAction != null &&
                  secondaryActionLabel != null) ...[
                const SizedBox(height: 4),
                TextButton(
                  onPressed: onSecondaryAction,
                  child: Text(
                    secondaryActionLabel!,
                    style: TextStyle(color: context.appColors.lineupLavender),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
