import 'package:fantasy/core/config/app_config.dart';
import 'package:fantasy/core/services/custom_bloc_observer.dart';
import 'package:fantasy/core/theme/theme_cubit.dart';
import 'package:fantasy/shared/cubit/dock_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fantasy/core/di/injection.dart';
import 'package:fantasy/core/router/app_router.dart';
import 'package:fantasy/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fantasy/firebase_options.dart';
import 'package:fantasy/firebase_options_development.dart'
    as development_firebase;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options:
        AppConfig.isDevelopment
            ? development_firebase.DefaultFirebaseOptions.currentPlatform
            : DefaultFirebaseOptions.currentPlatform,
  );

  Bloc.observer = CustomBlocObserver();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory:
        kIsWeb
            ? HydratedStorageDirectory.web
            : HydratedStorageDirectory(
              (await getApplicationDocumentsDirectory()).path,
            ),
  );

  await initDependencies();

  runApp(const FantaXi());
}

class FantaXi extends StatelessWidget {
  const FantaXi({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => DockCubit()),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder:
            (context, themeMode) => MaterialApp.router(
              title: 'FPL Stats',
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              routerConfig: AppRouter.router,
              debugShowCheckedModeBanner: false,
            ),
      ),
    );
  }
}
