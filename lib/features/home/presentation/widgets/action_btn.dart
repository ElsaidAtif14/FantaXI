
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/home/data/model/action_item.dart';
import 'package:flutter/widgets.dart';



class ActionBtn extends StatelessWidget {
  final ActionItem item;
  const ActionBtn({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: context.appColors.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appColors.outline),
        ),
        child: Column(
          children: [
            Text(item.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              item.label,
              style:  TextStyle(
                color: context.appColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: library_private_types_in_public_api
ActionItem makeAction(String icon, String label, VoidCallback onTap) =>
    ActionItem(icon: icon, label: label, onTap: onTap);
