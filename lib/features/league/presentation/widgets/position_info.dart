
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class PositionInfo extends StatelessWidget {
  const PositionInfo({super.key, required this.label, required this.value, this.detail});
  final String label;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: context.appColors.leagueSecondaryText,
          fontSize: 10,
          letterSpacing: .5,
        ),
      ),
      const SizedBox(height: 3),
      Row(
        children: [
          Text(
            value,
            style: TextStyle(
              color: context.appColors.leagueText,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                detail!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.appColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    ],
  );
}