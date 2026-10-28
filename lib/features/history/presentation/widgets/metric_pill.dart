
import 'package:fantasy/core/theme/app_colors.dart';
import 'package:flutter/widgets.dart';

class MetricPill extends StatelessWidget {
  const MetricPill({super.key, 
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.lineupControl,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.lineupTextSecondary),
        const SizedBox(width: 5),
        Text(
          '$label:',
          style: const TextStyle(
            color: AppColors.lineupTextSecondary,
            fontSize: 9,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
