

import 'package:flutter/material.dart';

class PointsGap extends StatelessWidget {
  const PointsGap({super.key, required this.pointsBehind});
  final int? pointsBehind;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      const Text(
        'POINTS TO #1',
        style: TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 10,
          letterSpacing: .5,
        ),
      ),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0x1A10B981),
          border: Border.all(color: const Color(0x3310B981)),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          pointsBehind == null ? '— pts' : '-$pointsBehind pts',
          style: const TextStyle(
            color: Color(0xFF34D399),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ],
  );
}
