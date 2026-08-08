import 'package:flutter/animation.dart';

/// Three durations, three curves. Hard budget of two moving things per screen —
/// any transition that does not communicate information gets removed.
class AppMotion {
  AppMotion._();

  // Durations
  static const Duration micro = Duration(milliseconds: 120);
  static const Duration short = Duration(milliseconds: 220);
  static const Duration long = Duration(milliseconds: 420);

  /// Replacement duration under `prefers-reduced-motion: reduce`.
  static const Duration reduced = Duration(milliseconds: 150);

  // Curves
  static const Curve easeOut = Cubic(0.16, 1, 0.3, 1);
  static const Curve easeIn = Cubic(0.7, 0, 0.84, 0);
  static const Curve easeInOut = Cubic(0.65, 0, 0.35, 1);
}
