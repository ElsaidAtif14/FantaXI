import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/core/di/injection.dart';
import 'package:fantasy/features/bootstrap/presentation/cubit/bootstrap_cubit.dart';
import 'package:fantasy/features/picks/presentation/cubit/picks_cubit.dart';
import 'package:fantasy/features/live/presentation/cubit/live_cubit.dart';
import 'package:fantasy/features/live/presentation/widgets/live_player_row.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:fantasy/features/picks/data/models/gameweek_picks_model.dart';
import 'package:fantasy/features/bootstrap/data/models/player_model.dart';
import 'package:fantasy/features/bootstrap/data/models/bootstrap_model.dart';
import 'package:fantasy/features/live/data/models/element_live_model.dart';
import 'package:fantasy/shared/widgets/app_navigation_dock.dart';

class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<PicksCubit>()),
        BlocProvider(create: (_) => sl<LiveCubit>()),
        BlocProvider(create: (_) => sl<BootstrapCubit>()..loadBootstrap()),
      ],
      child: FutureBuilder<int>(
        future: SharedPreferences.getInstance().then(
          (p) => p.getInt(AppConstants.entryIdKey) ?? 0,
        ),
        builder: (context, snap) {
          return const _LiveView();
        },
      ),
    );
  }
}

class _LiveView extends StatelessWidget {
  const _LiveView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppNavigationDock(currentIndex: 3),
      appBar: AppBar(
        title: const Text('Live Gameweek'),
        actions: [
          BlocBuilder<PicksCubit, PicksState>(
            builder: (ctx, state) {
              if (state is PicksLoaded) {
                return IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed:
                      () => ctx.read<LiveCubit>().loadLive(
                        state.picks.stats.event,
                      ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocListener<PicksCubit, PicksState>(
        listener: (context, state) {
          if (state is PicksLoaded) {
            context.read<LiveCubit>().loadLive(state.picks.stats.event);
          }
        },
        child: BlocBuilder<BootstrapCubit, BootstrapState>(
          builder: (context, bootState) {
            return BlocBuilder<PicksCubit, PicksState>(
              builder: (context, picksState) {
                return BlocBuilder<LiveCubit, LiveState>(
                  builder: (context, liveState) {
                    if (bootState is BootstrapLoading ||
                        picksState is PicksLoading ||
                        liveState is LiveLoading) {
                      return Skeletonizer(
                        enabled: true,
                        child: ListView.builder(
                          itemCount: 11,
                          padding: const EdgeInsets.all(16),
                          itemBuilder:
                              (c, i) => LivePlayerRow(
                                player: PlayerModel.dummy(),
                                pick: TeamPick.dummy(i + 1, 3),
                                liveData: ElementLiveModel.dummy(),
                                bootstrap: BootstrapModel.dummy(),
                              ),
                        ),
                      );
                    }
                    if (liveState is LiveError) {
                      return Center(
                        child: Text(
                          liveState.message,
                          style:  TextStyle(color: context.appColors.rankDown),
                        ),
                      );
                    }
                    if (bootState is BootstrapLoaded &&
                        picksState is PicksLoaded &&
                        liveState is LiveLoaded) {
                      final picks = picksState.picks.picks;
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: picks.length,
                        itemBuilder: (context, i) {
                          final pick = picks[i];
                          final player = bootState.data.getPlayer(pick.element);
                          final live = liveState.data.getPlayer(pick.element);
                          if (player == null || live == null) {
                            return const SizedBox.shrink();
                          }
                          return LivePlayerRow(
                            player: player,
                            pick: pick,
                            liveData: live,
                            bootstrap: bootState.data,
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
