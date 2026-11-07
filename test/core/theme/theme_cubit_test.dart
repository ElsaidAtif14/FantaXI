import 'package:fantasy/core/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

void main() {
  late _MemoryStorage storage;

  setUp(() {
    storage = _MemoryStorage();
    HydratedBloc.storage = storage;
  });

  tearDown(() async {
    await storage.close();
    HydratedBloc.storage = null;
  });

  test('selected theme is restored after recreating the cubit', () async {
    final themeCubit = ThemeCubit();
    expect(themeCubit.state, ThemeMode.light);

    themeCubit.setThemeMode(ThemeMode.dark);
    await themeCubit.close();

    final restoredCubit = ThemeCubit();
    expect(restoredCubit.state, ThemeMode.dark);

    restoredCubit.setThemeMode(ThemeMode.system);
    await restoredCubit.close();

    final systemCubit = ThemeCubit();
    expect(systemCubit.state, ThemeMode.system);
    await systemCubit.close();
  });

  test('unknown persisted values fall back to the initial theme', () async {
    storage.values['ThemeCubit'] = {'themeMode': 'invalid'};

    final themeCubit = ThemeCubit();
    expect(themeCubit.state, ThemeMode.light);
    await themeCubit.close();
  });
}

class _MemoryStorage implements Storage {
  final values = <String, dynamic>{};

  @override
  dynamic read(String key) => values[key];

  @override
  Future<void> write(String key, dynamic value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }

  @override
  Future<void> clear() async {
    values.clear();
  }

  @override
  Future<void> close() async {}
}
