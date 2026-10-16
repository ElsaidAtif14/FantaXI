import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/core/di/injection.dart';
import 'package:fantasy/features/bootstrap/presentation/cubit/bootstrap_cubit.dart';
import 'package:fantasy/features/live/presentation/cubit/live_cubit.dart';
import 'package:fantasy/features/manager/presentation/cubit/manager_cubit.dart';
import 'package:fantasy/features/picks/presentation/cubit/picks_cubit.dart';
import 'package:fantasy/features/picks/presentation/pages/picks_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PicksScreen extends StatefulWidget {
  final int? entryId;
  final int? initialGw;

  const PicksScreen({super.key, this.entryId, this.initialGw});

  @override
  State<PicksScreen> createState() => _PicksScreenState();
}

class _PicksScreenState extends State<PicksScreen> {
  late final Future<int> _savedEntryId = SharedPreferences.getInstance().then(
    (preferences) => preferences.getInt(AppConstants.entryIdKey) ?? 0,
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<PicksCubit>()),
        BlocProvider(create: (_) => sl<BootstrapCubit>()..loadBootstrap()),
        BlocProvider(create: (_) => sl<ManagerCubit>()),
        BlocProvider(create: (_) => sl<LiveCubit>()),
      ],
      child: Builder(
        builder:
            (context) => FutureBuilder<int>(
              future: _savedEntryId,
              builder: (context, snapshot) {
                final entryId = widget.entryId ?? snapshot.data;
                if (entryId != null &&
                    entryId > 0 &&
                    context.read<ManagerCubit>().state is ManagerInitial) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted &&
                        context.read<ManagerCubit>().state is ManagerInitial) {
                      context.read<ManagerCubit>().loadManager(entryId);
                    }
                  });
                }
                return PicksView(
                  initialGw: widget.initialGw,
                  managerId: entryId,
                  managerIdLoading:
                      widget.entryId == null &&
                      snapshot.connectionState != ConnectionState.done,
                );
              },
            ),
      ),
    );
  }
}
