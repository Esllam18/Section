// lib/core/animations/app_durations.dart

abstract final class AppDurations {
  static const instant    = Duration(milliseconds: 0);
  static const veryShort  = Duration(milliseconds: 500);
  static const short      = Duration(milliseconds: 800);
  static const medium     = Duration(milliseconds: 1200);
  static const long       = Duration(milliseconds: 1600);
  static const veryLong   = Duration(milliseconds: 2200);
  static const extraLong  = Duration(milliseconds: 3000);
  static const pageTransition = Duration(milliseconds: 350);
  static const splashDelay    = Duration(milliseconds: 2800);
}
