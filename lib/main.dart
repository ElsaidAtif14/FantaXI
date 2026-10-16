import 'package:fantasy/core/services/custom_bloc_observer.dart';
import 'package:flutter/material.dart';
import 'package:fantasy/core/di/injection.dart';
import 'package:fantasy/core/router/app_router.dart';
import 'package:fantasy/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer=CustomBlocObserver();
  await initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FPL Stats',
      theme: AppTheme.dark,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
