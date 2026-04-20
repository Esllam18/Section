// lib/core/navigation/navigation.dart
// Unified navigation — delegates to the single NavigationService navigatorKey.
import 'package:flutter/material.dart';
import 'package:section/core/services/navigation/navigation_service.dart';
import 'transition_type.dart';

abstract final class Navigation {
  /// Expose the navigator key so MaterialApp can consume it directly:
  ///   navigatorKey: Navigation.key
  static GlobalKey<NavigatorState> get key => NavigationService.navigatorKey;

  static NavigatorState get _nav =>
      NavigationService.navigatorKey.currentState!;

  // ── Named-route helpers ───────────────────────────────────────────────────
  static Future<T?> toNamed<T>(String route, {Object? args}) =>
      _nav.pushNamed<T>(route, arguments: args);

  static Future<T?> replaceNamed<T, R>(String route,
          {R? result, Object? args}) =>
      _nav.pushReplacementNamed<T, R>(route, result: result, arguments: args);

  static Future<T?> offAllNamed<T>(String route, {Object? args}) =>
      _nav.pushNamedAndRemoveUntil<T>(route, (_) => false, arguments: args);

  // ── Widget-route helpers ──────────────────────────────────────────────────
  static Future<T?> to<T>(Widget screen,
          {TransitionType t = TransitionType.slideRight}) =>
      _nav.push<T>(_route(screen, t));

  static Future<T?> off<T>(Widget screen,
          {TransitionType t = TransitionType.fade}) =>
      _nav.pushReplacement<T, dynamic>(_route(screen, t));

  static Future<T?> offAll<T>(Widget screen,
          {TransitionType t = TransitionType.fade}) =>
      _nav.pushAndRemoveUntil<T>(_route(screen, t), (_) => false);

  // ── Back ──────────────────────────────────────────────────────────────────
  static void back<T>([T? result]) {
    if (_nav.canPop()) _nav.pop<T>(result);
  }

  static bool canPop() => _nav.canPop();

  // ── Private: page-route builder ───────────────────────────────────────────
  static PageRoute<T> _route<T>(Widget screen, TransitionType type) {
    switch (type) {
      case TransitionType.fade:
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => screen,
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        );
      case TransitionType.slideUp:
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => screen,
          transitionsBuilder: (_, a, __, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 350),
        );
      case TransitionType.none:
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => screen,
          transitionDuration: Duration.zero,
        );
      default: // slideRight (and any other direction)
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => screen,
          transitionsBuilder: (_, a, __, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
        );
    }
  }
}
