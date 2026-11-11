/// Shared spacing and type scale for the Match Details feature.
///
/// These values are local to the feature so the global theme is not disturbed
/// while the screen keeps a consistent rhythm across all of its sections.
class MatchDetailsStyle {
  MatchDetailsStyle._();

  // Spacing
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 20;
  static const double spaceXxl = 24;

  /// Horizontal gutter used by every section on the screen.
  static const double gutter = 16;

  /// Vertical gap between two top-level sections.
  static const double sectionGap = 20;

  // Typography
  static const double microSize = 10;
  static const double labelSize = 11;
  static const double bodySize = 12.5;
  static const double bodyStrongSize = 13;
  static const double emphasisSize = 14;
  static const double sectionTitleSize = 16;
  static const double scoreSize = 40;

  static const double cardRadius = 14;
  static const double panelRadius = 12;
}
