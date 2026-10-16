import 'package:fantasy/core/router/app_router.dart';
import 'package:fantasy/core/theme/app_colors.dart';
import 'package:fantasy/features/bootstrap/presentation/cubit/bootstrap_cubit.dart';
import 'package:fantasy/shared/widgets/custom_app_bar.dart';
import 'package:fantasy/features/live/presentation/cubit/live_cubit.dart';
import 'package:fantasy/features/manager/data/models/fantasy_manager_model.dart';
import 'package:fantasy/features/manager/presentation/cubit/manager_cubit.dart';
import 'package:fantasy/features/picks/presentation/cubit/picks_cubit.dart';
import 'package:fantasy/features/picks/presentation/widgets/squad_content_view.dart';
import 'package:fantasy/shared/widgets/squad_loading_view.dart';
import 'package:fantasy/features/picks/presentation/widgets/error_message_view.dart';
import 'package:fantasy/shared/widgets/app_navigation_dock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PicksView extends StatefulWidget {
  final int? initialGw;
  final int? managerId;
  final bool managerIdLoading;

  const PicksView({
    super.key,
    this.initialGw,
    this.managerId,
    this.managerIdLoading = false,
  });

  @override
  State<PicksView> createState() => _PicksViewState();
}

class _PicksViewState extends State<PicksView> {
  int? _currentGw;

  @override
  void initState() {
    super.initState();
    _currentGw = widget.initialGw;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManagerCubit, ManagerState>(
      builder: (context, managerState) {
        return Scaffold(
          extendBody: true,
          backgroundColor: AppColors.lineupBackground,
          appBar: CustomAppBar(title: 'Squad', isHome: false),

          bottomNavigationBar: const AppNavigationDock(
            currentIndex: 1,
            showLive: true,
          ),
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.lineupBackground,
                  AppColors.lineupBackground,
                  Color(0xFF161B2E),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: MultiBlocListener(
                listeners: [
                  BlocListener<BootstrapCubit, BootstrapState>(
                    listener: (context, _) => _checkAndLoadPicks(context),
                  ),
                  BlocListener<ManagerCubit, ManagerState>(
                    listener: (context, _) => _checkAndLoadPicks(context),
                  ),
                ],
                child: _buildBody(context, managerState),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ManagerState managerState) {
    return BlocBuilder<BootstrapCubit, BootstrapState>(
      builder: (context, bootstrapState) {
        return BlocBuilder<PicksCubit, PicksState>(
          builder: (context, picksState) {
            return BlocBuilder<LiveCubit, LiveState>(
              builder: (context, liveState) {
                if (!widget.managerIdLoading &&
                    (widget.managerId == null || widget.managerId == 0)) {
                  return ErrorMessageView(
                    icon: Icons.person_search_outlined,
                    message: 'Set up your manager to view your squad.',
                    actionLabel: 'Set up manager',
                    onAction: () => context.go(AppRouter.onboarding),
                  );
                }
                if (managerState is ManagerError) {
                  return ErrorMessageView(
                    icon: Icons.cloud_off_outlined,
                    message: managerState.message,
                    actionLabel: 'Try Again',
                    onAction:
                        () => context.read<ManagerCubit>().loadManager(
                          widget.managerId!,
                        ),
                  );
                }
                if (bootstrapState is BootstrapError) {
                  return ErrorMessageView(
                    icon: Icons.cloud_off_outlined,
                    message: bootstrapState.message,
                    actionLabel: 'Retry',
                    onAction:
                        () => context.read<BootstrapCubit>().loadBootstrap(),
                  );
                }
                if (picksState is PicksError) {
                  return ErrorMessageView(
                    icon: Icons.cloud_off_outlined,
                    message: picksState.message,
                    actionLabel: 'Retry',
                    onAction: () => _loadGameweek(context, managerState),
                  );
                }

                if (widget.managerIdLoading ||
                    managerState is ManagerInitial ||
                    managerState is ManagerLoading ||
                    bootstrapState is BootstrapInitial ||
                    bootstrapState is BootstrapLoading ||
                    picksState is PicksInitial ||
                    picksState is PicksLoading ||
                    liveState is LiveInitial ||
                    liveState is LiveLoading) {
                  return const SquadLoadingView();
                }

                if (managerState is! ManagerLoaded ||
                    bootstrapState is! BootstrapLoaded) {
                  return const SquadLoadingView();
                }

                final picks =
                    picksState is PicksLoaded ? picksState.picks : null;
                final live = liveState is LiveLoaded ? liveState.data : null;
                final gameweek =
                    _currentGw ?? managerState.manager.currentEvent;
                return SquadContentView(
                  gameweek: gameweek,
                  manager: managerState.manager,
                  bootstrap: bootstrapState.data,
                  picks: picks,
                  live: live,
                  liveError: liveState is LiveError ? liveState.message : null,
                  onPreviousGameweek:
                      () => _changeGameweek(
                        context,
                        managerState.manager,
                        gameweek - 1,
                      ),
                  onNextGameweek:
                      () => _changeGameweek(
                        context,
                        managerState.manager,
                        gameweek + 1,
                      ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _checkAndLoadPicks(BuildContext context) {
    final bootstrapState = context.read<BootstrapCubit>().state;
    final managerState = context.read<ManagerCubit>().state;
    if (bootstrapState is BootstrapLoaded && managerState is ManagerLoaded) {
      _currentGw ??= widget.initialGw ?? managerState.manager.currentEvent;
      if (context.read<PicksCubit>().state is PicksInitial) {
        context.read<PicksCubit>().loadPicks(
          managerState.manager.id,
          _currentGw!,
        );
        context.read<LiveCubit>().loadLive(_currentGw!);
      }
    }
  }

  void _changeGameweek(
    BuildContext context,
    FantasyManagerModel manager,
    int gameweek,
  ) {
    setState(() => _currentGw = gameweek);
    context.read<PicksCubit>().loadPicks(manager.id, gameweek);
    context.read<LiveCubit>().loadLive(gameweek);
  }

  void _loadGameweek(BuildContext context, ManagerState managerState) {
    if (managerState is ManagerLoaded) {
      final gameweek = _currentGw ?? managerState.manager.currentEvent;
      context.read<PicksCubit>().loadPicks(managerState.manager.id, gameweek);
      context.read<LiveCubit>().loadLive(gameweek);
    }
  }
}
