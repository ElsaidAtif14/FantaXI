import 'package:fantasy/features/history/data/models/manager_history_model.dart';
import 'package:fantasy/features/history/presentation/cubit/history_cubit.dart';
import 'package:fantasy/features/history/presentation/widgets/history_content.dart';
import 'package:fantasy/features/picks/presentation/widgets/error_message_view.dart';
import 'package:fantasy/shared/widgets/app_navigation_dock.dart';
import 'package:fantasy/shared/widgets/custom_app_bar.dart';
import 'package:fantasy/shared/cubit/dock_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HistoryViewBody extends StatefulWidget {
  const HistoryViewBody({super.key});

  @override
  State<HistoryViewBody> createState() => _HistoryViewBodyState();
}

class _HistoryViewBodyState extends State<HistoryViewBody> {
  int? _selectedGameweek;
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

  void _selectGameweek(int gameweek) {
    setState(() => _selectedGameweek = gameweek);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const AppNavigationDock(
        currentIndex: 4,
        showLive: true,
      ),
      appBar: CustomAppBar(title: 'History', showActions: false),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return Skeletonizer(
              enabled: true,
              child: HistoryContent(
                history: ManagerHistoryModel.dummy(),
                controller: _scrollController,
                selectedGameweek: 5,
                onGameweekSelected: _selectGameweek,
              ),
            );
          }
          if (state is HistoryError) {
            return Center(
              child: ErrorMessageView(
                icon: Icons.cloud_off_outlined,
                message: state.message,
                actionLabel: 'Try again',
                onAction: () => context.read<HistoryCubit>().retry(),
              ),
            );
          }
          if (state is HistoryLoaded) {
            final history = state.history;
            final latestGameweek =
                history.currentSeason.isEmpty
                    ? null
                    : history.currentSeason
                        .map((event) => event.event)
                        .reduce((a, b) => a > b ? a : b);
            final selectedGameweek =
                history.currentSeason.any(
                      (event) => event.event == _selectedGameweek,
                    )
                    ? _selectedGameweek
                    : latestGameweek;

            return HistoryContent(
              history: history,
              controller: _scrollController,
              selectedGameweek: selectedGameweek,
              onGameweekSelected: _selectGameweek,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
