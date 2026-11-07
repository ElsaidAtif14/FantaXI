import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({
    required this.selectedMode,
    required this.onChanged,
    super.key,
  });

  final ThemeMode selectedMode;
  final ValueChanged<ThemeMode> onChanged;

  static const _options = [
    (
      mode: ThemeMode.light,
      title: 'Light',
      subtitle: 'Bright and clear',
      icon: Icons.light_mode_rounded,
    ),
    (
      mode: ThemeMode.dark,
      title: 'Dark',
      subtitle: 'Easy on the eyes',
      icon: Icons.dark_mode_rounded,
    ),
    (
      mode: ThemeMode.system,
      title: 'System',
      subtitle: 'Follow device settings',
      icon: Icons.settings_suggest_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.palette_outlined,
              color: colors.lineupLavender,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Appearance',
              style: TextStyle(
                color: colors.lineupText,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children:
              _options.map((option) {
                final isSelected = selectedMode == option.mode;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => onChanged(option.mode),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? colors.lineupLavender.withValues(
                                    alpha: 0.12,
                                  )
                                  : colors.lineupPanel,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                isSelected
                                    ? colors.lineupLavender
                                    : colors.outline,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              option.icon,
                              color:
                                  isSelected
                                      ? colors.lineupLavender
                                      : colors.lineupTextSecondary,
                              size: 23,
                            ),
                            const SizedBox(height: 9),
                            Text(
                              option.title,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? colors.lineupLavender
                                        : colors.lineupText,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isSelected ? 'Active' : option.subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colors.lineupTextSecondary,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
