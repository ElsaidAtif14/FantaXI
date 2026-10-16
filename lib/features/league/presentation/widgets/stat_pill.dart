
import 'package:flutter/material.dart';

class StatPill extends StatelessWidget {
  const StatPill({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .05),
      border: Border.all(color: Colors.white.withValues(alpha: .1)),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      label,
      style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 10),
    ),
  );
}