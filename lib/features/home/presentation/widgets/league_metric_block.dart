import 'package:fantasy/core/theme/app_colors.dart';
import 'package:fantasy/features/home/data/model/league_metric.dart';
import 'package:flutter/widgets.dart';



class LeagueMetricBlock extends StatelessWidget {
  final LeagueMetric metric;

  const LeagueMetricBlock({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            metric.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.45,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              if (metric.icon != null) ...[
                Icon(metric.icon, color: metric.color, size: 13),
                const SizedBox(width: 3),
              ],
              Flexible(
                child: Text(
                  metric.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: metric.color,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
