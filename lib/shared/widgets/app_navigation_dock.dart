import 'dart:math' as math;
import 'dart:ui';

import 'package:fantasy/core/router/app_router.dart';
import 'package:fantasy/shared/widgets/dock_items.dart';
import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppNavigationDock extends StatelessWidget {
  const AppNavigationDock({
    super.key,
    required this.currentIndex,
    this.showLive = true,
  });

  /// Index inside the *visible* destinations list
  /// (so if Live is hidden, History becomes index 3 not 4).
  final int currentIndex;
  final bool showLive;

  static const double dockHeight = 56;
  static const double _bottomGap = 4;

  /// Total height the dock occupies above the safe area.
  /// Use it as bottom padding for scrollable content behind the dock.
  static const double occupiedHeight = dockHeight + _bottomGap;

  static const _allDestinations = [
    DockDestination('Home', Icons.space_dashboard_rounded, AppRouter.home),
    DockDestination('Squad', Icons.people, AppRouter.picks),
    DockDestination('Market', Icons.swap_horiz_rounded, AppRouter.market),
    // DockDestination('Live', Icons.bolt_rounded, AppRouter.live),
    DockDestination('Matches', Icons.sports_soccer, AppRouter.matches),
    DockDestination('History', Icons.show_chart_rounded, AppRouter.history),
  ];

  @override
  Widget build(BuildContext context) {
    final destinations =
        showLive
            ? _allDestinations
            : _allDestinations
                .where((destination) => destination.label != 'Live')
                .toList();

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, _bottomGap),
        child: SizedBox(
          height: dockHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const horizontalPadding = 16.0; // 8 left + 8 right
              const gap = 4.0;
              final gaps =
                  gap * math.max(0, destinations.length - 1).toDouble();
              final widthPerItem =
                  destinations.isEmpty
                      ? 0.0
                      : (constraints.maxWidth - horizontalPadding - gaps) /
                          destinations.length;
              final itemWidth =
                  math.min(56.0, math.max(0.0, widthPerItem)).toDouble();

              return Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.appColors.surface.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: context.appColors.outline.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (
                              var index = 0;
                              index < destinations.length;
                              index++
                            ) ...[
                              if (index > 0) const SizedBox(width: gap),
                              SizedBox(
                                width: itemWidth,
                                height: 48,
                                child: DockItem(
                                  destination: destinations[index],
                                  selected: currentIndex == index,
                                  onTap:
                                      () =>
                                          context.go(destinations[index].route),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
