import 'package:fantasy/features/home/presentation/widgets/home_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/core/di/injection.dart';
import 'package:fantasy/features/manager/presentation/cubit/manager_cubit.dart';
import 'package:fantasy/features/bootstrap/presentation/cubit/bootstrap_cubit.dart';
import 'package:fantasy/features/live/presentation/cubit/live_cubit.dart';
import 'package:fantasy/features/picks/presentation/cubit/picks_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<int> _entryIdFuture;
  bool _managerLoadStarted = false;

  @override
  void initState() {
    super.initState();
    _entryIdFuture = SharedPreferences.getInstance().then(
      (prefs) => prefs.getInt(AppConstants.entryIdKey) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ManagerCubit>()),
        BlocProvider(create: (_) => sl<BootstrapCubit>()..loadBootstrap()),
        BlocProvider(create: (_) => sl<PicksCubit>()),
        BlocProvider(create: (_) => sl<LiveCubit>()),
      ],
      child: BlocListener<ManagerCubit, ManagerState>(
        listener: (context, state) {
          if (state is ManagerLoaded && state.manager.currentEvent > 0) {
            context.read<PicksCubit>().loadPicks(
              state.manager.id,
              state.manager.currentEvent,
            );
            context.read<LiveCubit>().loadLive(state.manager.currentEvent);
          }
        },
        child: FutureBuilder<int>(
          future: _entryIdFuture,
          builder: (context, snap) {
            if (snap.hasData && snap.data! > 0 && !_managerLoadStarted) {
              _managerLoadStarted = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.read<ManagerCubit>().loadManager(snap.data!);
                }
              });
            }
            return HomeBody(
              managerId: snap.data,
              isEntryIdLoading: snap.connectionState != ConnectionState.done,
              entryIdError: snap.hasError ? snap.error.toString() : null,
            );
          },
        ),
      ),
    );
  }
}
