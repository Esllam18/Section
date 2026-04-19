import 'package:flutter/material.dart';
import 'navigation_service.dart';
import 'transition_type.dart';

class Navigation {
  static Future<T?> to<T>(Widget screen, {TransitionType type = TransitionType.slideRight}) =>
      NavigationService.navigator.push<T>(_route(screen, type));

  static Future<T?> off<T>(Widget screen, {TransitionType type = TransitionType.fade}) =>
      NavigationService.navigator.pushReplacement<T, dynamic>(_route(screen, type));

  static Future<T?> offAll<T>(Widget screen, {TransitionType type = TransitionType.fade}) =>
      NavigationService.navigator.pushAndRemoveUntil<T>(_route(screen, type), (_) => false);

  static Future<T?> offAllNamed<T>(String route, {Object? arguments}) =>
      NavigationService.navigator.pushNamedAndRemoveUntil<T>(route, (_) => false, arguments: arguments);

  static void back<T>([T? result]) => NavigationService.navigator.pop(result);
  static bool canPop() => NavigationService.navigator.canPop();

  static PageRoute<T> _route<T>(Widget screen, TransitionType type) {
    switch (type) {
      case TransitionType.fade:
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => screen,
          transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
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
        return PageRouteBuilder(pageBuilder: (_, __, ___) => screen, transitionDuration: Duration.zero);
      default:
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
