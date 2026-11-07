import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class DockItem extends StatelessWidget {
  const DockItem({
    super.key,
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final DockDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        selected
            ? context.appColors.lineupLavender
            : context.appColors.lineupTextSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color:
                  selected
                      ? context.appColors.lineupPurple.withValues(alpha: .2)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              boxShadow:
                  selected
                      ? [
                        BoxShadow(
                          color: context.appColors.lineupPurple.withValues(
                            alpha: .28,
                          ),
                          blurRadius: 12,
                        ),
                      ]
                      : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(destination.icon, color: color, size: 16),
                const SizedBox(height: 2),
                Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    height: 1.1,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DockDestination {
  const DockDestination(this.label, this.icon, this.route);

  final String label;
  final IconData icon;
  final String route;
}
