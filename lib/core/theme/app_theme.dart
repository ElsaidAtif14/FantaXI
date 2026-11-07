import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(AppThemeColors.light, Brightness.light);
  static ThemeData get dark => _build(AppThemeColors.dark, Brightness.dark);

  static ThemeData _build(AppThemeColors colors, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      colorScheme:
          isLight
              ? ColorScheme.light(
                primary: colors.primary,
                secondary: colors.electricBlue,
                tertiary: colors.warmOrange,
                surface: colors.surface,
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onSurface: colors.textPrimary,
              )
              : ColorScheme.dark(
                primary: colors.primary,
                secondary: colors.electricBlue,
                tertiary: colors.warmOrange,
                surface: colors.surface,
                onPrimary: Colors.white,
                onSecondary: Colors.black,
                onSurface: colors.textPrimary,
              ),
      textTheme: GoogleFonts.outfitTextTheme(_baseTextTheme(colors)),
      appBarTheme: _appBarTheme(colors),
      cardTheme: _cardTheme(colors),
      inputDecorationTheme: _inputTheme(colors),
      elevatedButtonTheme: _buttonTheme(colors),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.surface,
        contentTextStyle: TextStyle(
          color: colors.textPrimary,
          fontFamily: 'Outfit',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.outline),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.outline,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        modalBackgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: colors.textMuted,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      extensions: <ThemeExtension<dynamic>>[colors],
    );
  }

  static TextTheme _baseTextTheme(AppThemeColors colors) => TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w800,
      color: colors.textPrimary,
      letterSpacing: -0.5,
    ),
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: colors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: colors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: colors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: colors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: colors.textSecondary,
    ),
  );

  static AppBarTheme _appBarTheme(AppThemeColors colors) => AppBarTheme(
    backgroundColor: colors.background,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    shadowColor: Colors.transparent,
    titleTextStyle: TextStyle(
      fontFamily: 'Outfit',
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: colors.textPrimary,
    ),
    iconTheme: IconThemeData(color: colors.textPrimary),
  );

  static CardThemeData _cardTheme(AppThemeColors colors) => CardThemeData(
    color: colors.card,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(color: colors.outline),
    ),
    margin: EdgeInsets.zero,
  );

  static InputDecorationTheme _inputTheme(AppThemeColors colors) =>
      InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primaryLight, width: 1.5),
        ),
        hintStyle: TextStyle(color: colors.textMuted, fontFamily: 'Outfit'),
      );

  static ElevatedButtonThemeData _buttonTheme(AppThemeColors colors) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
