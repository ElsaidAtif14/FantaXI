import 'package:fantasy/core/constants/app_constants.dart';
import 'package:fantasy/core/router/app_router.dart';
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/core/theme/theme_cubit.dart';
import 'package:fantasy/features/home/presentation/widgets/home_feedback.dart';
import 'package:fantasy/features/home/presentation/widgets/theme_mode_selector.dart';
import 'package:fantasy/shared/widgets/custom_app_bar.dart';
import 'package:fantasy/features/home/presentation/widgets/leagues_hub_content.dart';
import 'package:fantasy/features/home/presentation/widgets/home_manager_card.dart';
import 'package:fantasy/features/home/presentation/widgets/home_mvp_spotlight_card.dart';
import 'package:fantasy/features/home/presentation/widgets/home_progress_card.dart';
import 'package:fantasy/features/home/presentation/widgets/home_stats_grid.dart';
import 'package:fantasy/features/bootstrap/presentation/cubit/bootstrap_cubit.dart';
import 'package:fantasy/features/live/presentation/cubit/live_cubit.dart';
import 'package:fantasy/features/manager/data/models/fantasy_manager_model.dart';
import 'package:fantasy/features/manager/presentation/cubit/manager_cubit.dart';
import 'package:fantasy/features/picks/presentation/cubit/picks_cubit.dart';
import 'package:fantasy/shared/widgets/app_navigation_dock.dart';
import 'package:fantasy/shared/widgets/app_snack_bar.dart';
import 'package:fantasy/shared/cubit/dock_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({
    super.key,
    this.managerId,
    this.onRefreshManager,
    this.isEntryIdLoading = false,
    this.entryIdError,
  });

  final int? managerId;
  final ValueChanged<int>? onRefreshManager;
  final bool isEntryIdLoading;
  final String? entryIdError;

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  late final ScrollController _scrollController;
  bool _isCurrentRoute = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    if (_isCurrentRoute) context.read<DockCubit>().show();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients || !_isCurrentRoute) return;
    context.read<DockCubit>().handleScroll(
      _scrollController.position.userScrollDirection,
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManagerCubit, ManagerState>(
      builder: (context, state) {
        final hasManagerId = widget.managerId != null && widget.managerId! > 0;
        final managerLoading =
            widget.isEntryIdLoading ||
            state is ManagerLoading ||
            (state is ManagerInitial && hasManagerId);

        return Scaffold(
          extendBody: true,
          backgroundColor: context.appColors.marketBackground,
          appBar: CustomAppBar(
            title: 'Home',
            onSettingsTap:
                () => _showSettings(context, hasManagerId: hasManagerId),
            showActions: true,
          ),
          bottomNavigationBar: const AppNavigationDock(currentIndex: 0),
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.appColors.marketBackground,
                  context.appColors.marketBackground,
                  Color(0xFF161B2E),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                if (managerLoading)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    sliver: SliverToBoxAdapter(
                      child: Skeletonizer(
                        enabled: true,
                        child: IgnorePointer(
                          child: _HomeLoadingContent(
                            manager: FantasyManagerModel.dummy(),
                          ),
                        ),
                      ),
                    ),
                  )
                else if (state is ManagerLoaded)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        HomeManagerCard(
                          manager: state.manager,
                          onRefresh:
                              () => widget.onRefreshManager?.call(
                                state.manager.id,
                              ),
                          onShare:
                              () => _copyManagerSummary(context, state.manager),
                        ),
                        const SizedBox(height: 12),
                        HomeStatsGrid(manager: state.manager),
                        const SizedBox(height: 12),
                        HomeProgressCard(manager: state.manager),
                        const SizedBox(height: 14),
                        _buildMvpSpotlight(context, state.manager),
                        const SizedBox(height: 22),
                        LeaguesHubContent(manager: state.manager),
                        const SizedBox(height: 40),
                      ]),
                    ),
                  )
                else if (widget.entryIdError != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: HomeFeedback(
                      icon: Icons.storage_rounded,
                      title: 'Could not read your manager ID',
                      message: widget.entryIdError!,
                      actionLabel: 'Open setup',
                      onAction:
                          () => _showSettings(context, hasManagerId: false),
                    ),
                  )
                else if (state is ManagerError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: HomeFeedback(
                      icon: Icons.cloud_off_rounded,
                      title: 'Could not load your manager',
                      message: state.message,
                      actionLabel: 'Try again',
                      onAction:
                          hasManagerId
                              ? () => context.read<ManagerCubit>().loadManager(
                                widget.managerId!,
                              )
                              : null,
                      secondaryActionLabel: 'Change Manager ID',
                      onSecondaryAction:
                          () => _showSettings(
                            context,
                            hasManagerId: hasManagerId,
                          ),
                    ),
                  )
                else if (widget.managerId == null || widget.managerId! <= 0)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: HomeFeedback(
                      icon: Icons.person_add_alt_1_rounded,
                      title: 'Add your manager ID',
                      message:
                          'Connect your FPL team to see your points, rank, and leagues.',
                      actionLabel: 'Set Manager ID',
                      onAction:
                          () => _showSettings(context, hasManagerId: false),
                    ),
                  )
                else
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: context.appColors.lineupMint,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettings(BuildContext context, {required bool hasManagerId}) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (sheetContext) => BlocBuilder<ThemeCubit, ThemeMode>(
            builder:
                (sheetContext, themeMode) => Container(
                  decoration: BoxDecoration(
                    color: sheetContext.appColors.lineupSurface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ThemeModeSelector(
                          selectedMode: themeMode,
                          onChanged: (mode) {
                            sheetContext.read<ThemeCubit>().setThemeMode(mode);
                          },
                        ),
                        const SizedBox(height: 16),
                        Divider(color: sheetContext.appColors.outline),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.person_outline_rounded,
                            color: sheetContext.appColors.lineupLavender,
                          ),
                          title: Text(
                            hasManagerId
                                ? 'Change Manager ID'
                                : 'Set Manager ID',
                            style: TextStyle(
                              color: sheetContext.appColors.lineupText,
                            ),
                          ),
                          onTap: () async {
                            Navigator.of(sheetContext).pop();

                            final prefs = await SharedPreferences.getInstance();
                            await prefs.remove(AppConstants.entryIdKey);

                            if (context.mounted) {
                              context.go(AppRouter.onboarding);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  Widget _buildMvpSpotlight(BuildContext context, FantasyManagerModel manager) {
    return BlocBuilder<BootstrapCubit, BootstrapState>(
      builder: (context, bootstrapState) {
        return BlocBuilder<PicksCubit, PicksState>(
          builder: (context, picksState) {
            return BlocBuilder<LiveCubit, LiveState>(
              builder: (context, liveState) {
                final errorMessage =
                    picksState is PicksError
                        ? 'Manager picks are unavailable'
                        : liveState is LiveError
                        ? 'Live scores are unavailable'
                        : bootstrapState is BootstrapError
                        ? 'Player data is unavailable'
                        : null;
                final isLoading =
                    picksState is PicksInitial ||
                    picksState is PicksLoading ||
                    liveState is LiveInitial ||
                    liveState is LiveLoading ||
                    bootstrapState is BootstrapInitial ||
                    bootstrapState is BootstrapLoading;

                return HomeMvpSpotlightCard(
                  gameweek: manager.currentEvent,
                  picks: picksState is PicksLoaded ? picksState.picks : null,
                  bootstrap:
                      bootstrapState is BootstrapLoaded
                          ? bootstrapState.data
                          : null,
                  liveData: liveState is LiveLoaded ? liveState.data : null,
                  isLoading: isLoading,
                  unavailableMessage: errorMessage,
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _copyManagerSummary(
    BuildContext context,
    FantasyManagerModel manager,
  ) async {
    await Clipboard.setData(
      ClipboardData(
        text:
            '${manager.teamName} — ${manager.fullName} · '
            'GW${manager.activeGW} · ${manager.totalPoints} pts · '
            'Rank ${manager.rankFormatted}',
      ),
    );
    if (context.mounted) {
      AppSnackBar.show(
        context,
        'Manager summary copied',
        type: AppSnackBarType.success,
      );
    }
  }
}

class _HomeLoadingContent extends StatelessWidget {
  const _HomeLoadingContent({required this.manager});

  final FantasyManagerModel manager;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      HomeManagerCard(manager: manager),
      const SizedBox(height: 12),
      HomeStatsGrid(manager: manager),
      const SizedBox(height: 12),
      HomeProgressCard(manager: manager),
      const SizedBox(height: 14),
      HomeMvpSpotlightCard(gameweek: manager.currentEvent, isLoading: true),
      const SizedBox(height: 22),
      LeaguesHubContent(manager: manager),
    ],
  );
}
