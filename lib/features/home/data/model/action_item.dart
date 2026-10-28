import 'package:flutter/widgets.dart';

class ActionItem {
  final String icon;
  final String label;
  final VoidCallback onTap;
  const ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}