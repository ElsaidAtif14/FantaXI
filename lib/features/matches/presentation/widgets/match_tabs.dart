import 'package:fantasy/core/theme/app_theme_colors.dart';
import 'package:fantasy/features/matches/presentation/widgets/match_details_style.dart';
import 'package:flutter/material.dart';

const matchDetailTabs = [
  'Timeline',
  'Lineups',
  'Stats',
  'Commentary',
  'Table Impact',
];

/// Horizontal pill navigation. The selected pill is scrolled into view, but
/// the bar itself is never pinned to the top of the page.
class MatchTabs extends StatefulWidget {
  const MatchTabs({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  State<MatchTabs> createState() => _MatchTabsState();
}

class _MatchTabsState extends State<MatchTabs> {
  final _controller = ScrollController();
  final _scrollKey = GlobalKey();
  late final List<GlobalKey> _pillKeys = List.generate(
    matchDetailTabs.length,
    (_) => GlobalKey(),
  );

  @override
  void initState() {
    super.initState();
    _scheduleReveal();
  }

  @override
  void didUpdateWidget(covariant MatchTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _scheduleReveal();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scheduleReveal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      final pillContext =
          _pillKeys[widget.selectedIndex.clamp(0, _pillKeys.length - 1)]
              .currentContext;
      final viewportContext = _scrollKey.currentContext;
      if (pillContext == null || viewportContext == null) return;
      final pillBox = pillContext.findRenderObject();
      final viewportBox = viewportContext.findRenderObject();
      if (pillBox is! RenderBox || viewportBox is! RenderBox) return;
      final offset = pillBox.localToGlobal(Offset.zero, ancestor: viewportBox);
      final target =
          _controller.offset +
          offset.dx -
          (viewportBox.size.width - pillBox.size.width) / 2;
      final max = _controller.position.maxScrollExtent;
      if (max <= 0) return;
      final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations;
      _controller.animateTo(
        target.clamp(0.0, max),
        duration:
            (reduceMotion ?? false)
                ? Duration.zero
                : const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      MatchDetailsStyle.gutter,
      MatchDetailsStyle.sectionGap,
      MatchDetailsStyle.gutter,
      0,
    ),
    child: SingleChildScrollView(
      key: _scrollKey,
      controller: _controller,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < matchDetailTabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            _TabPill(
              key: _pillKeys[i],
              label: matchDetailTabs[i],
              selected: widget.selectedIndex == i,
              onTap: () => widget.onSelected(i),
            ),
          ],
        ],
      ),
    ),
  );
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: '$label tab',
    child: Material(
      color:
          selected
              ? context.appColors.lineupLavender
              : context.appColors.lineupPanel,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40, minWidth: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color:
                    selected
                        ? context.appColors.marketSelectedText
                        : context.appColors.lineupTextSecondary,
                fontSize: MatchDetailsStyle.labelSize + .5,
                fontWeight: FontWeight.w700,
                letterSpacing: .1,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
