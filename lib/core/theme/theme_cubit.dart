import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  void setThemeMode(ThemeMode themeMode) {
    if (themeMode != state) emit(themeMode);
  }

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) => switch (json['themeMode']) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => null,
  };

  @override
  Map<String, String> toJson(ThemeMode themeMode) => {
    'themeMode': themeMode.name,
  };
}
