/// 4-pt spacing scale, named by step. Never type a raw number in a widget — use
/// one of these or a role alias. Two shape languages only: 12 for surfaces, 999
/// for the rating pill.
class AppSpacing {
  AppSpacing._();

  // Scale
  static const double xs3 = 2;
  static const double xs2 = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xl2 = 40;
  static const double xl3 = 48;
  static const double xl4 = 64;

  // Role aliases — what most widgets actually need
  static const double screenPadding = md;
  static const double cardPadding = sm;
  static const double sectionGap = xl;
  static const double listGap = sm;

  // Radii
  static const double radiusInput = 8;
  static const double radiusCard = 12;
  static const double radiusSheet = 16;
  static const double radiusPill = 999;
}
