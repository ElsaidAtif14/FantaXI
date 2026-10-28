
import 'package:fantasy/core/theme/app_colors.dart';
import 'package:flutter/widgets.dart';

class Tag extends StatelessWidget {
  const Tag({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.lineupLavender.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.lineupLavender,
        fontSize: 9,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
