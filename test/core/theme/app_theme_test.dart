import 'package:fantasy/core/theme/app_colors.dart';
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('light and dark themes register matching color extensions', () {
    final light = _theme(AppThemeColors.light, Brightness.light);
    final dark = _theme(AppThemeColors.dark, Brightness.dark);

    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
    expect(
      light.extension<AppThemeColors>()?.background,
      AppColors.lightBackground,
    );
    expect(
      dark.extension<AppThemeColors>()?.background,
      AppColors.darkBackground,
    );
  });

  testWidgets('app colors update when the active theme changes', (
    tester,
  ) async {
    Widget themedApp(ThemeMode mode) => MaterialApp(
      theme: _theme(AppThemeColors.light, Brightness.light),
      darkTheme: _theme(AppThemeColors.dark, Brightness.dark),
      themeMode: mode,
      home: Builder(
        builder:
            (context) => ColoredBox(
              key: const ValueKey('themed-background'),
              color: context.appColors.background,
            ),
      ),
    );

    await tester.pumpWidget(themedApp(ThemeMode.light));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ColoredBox>(find.byKey(const ValueKey('themed-background')))
          .color,
      AppColors.lightBackground,
    );

    await tester.pumpWidget(themedApp(ThemeMode.dark));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ColoredBox>(find.byKey(const ValueKey('themed-background')))
          .color,
      AppColors.darkBackground,
    );
  });
}

ThemeData _theme(AppThemeColors colors, Brightness brightness) =>
    ThemeData(brightness: brightness, extensions: [colors]);
