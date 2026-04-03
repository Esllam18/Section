// lib/core/navigation/navigation_service.dart
import 'package:flutter/material.dart';
import 'transition_type.dart';

class NavigationService {
  NavigationService._();
  static final NavigationService instance = NavigationService._();
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  NavigatorState get _nav => navigatorKey.currentState!;

  Route<T> _build<T>(Widget page, TransitionType type) {
    switch (type) {
      case TransitionType.fade:
        return PageRouteBuilder<T>(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        );
      case TransitionType.scale:
        return PageRouteBuilder<T>(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (_, a, __, c) => ScaleTransition(
            scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack), child: c),
        );
      case TransitionType.slideFromBottom:
        return PageRouteBuilder<T>(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (_, a, __, c) {
            final t = Tween(begin: const Offset(0, 1), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOutCubic));
            return SlideTransition(position: a.drive(t), child: c);
          },
        );
      case TransitionType.none:
        return PageRouteBuilder<T>(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        );
      case TransitionType.slide:
        return PageRouteBuilder<T>(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (_, a, __, c) {
            final t = Tween(begin: const Offset(1, 0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOutCubic));
            return SlideTransition(position: a.drive(t), child: c);
          },
        );
    }
  }

  Future<T?> push<T>(Widget p, {TransitionType transition = TransitionType.slide}) =>
      _nav.push<T>(_build<T>(p, transition));
  Future<T?> replace<T, R>(Widget p, {TransitionType transition = TransitionType.slide, R? result}) =>
      _nav.pushReplacement<T, R>(_build<T>(p, transition), result: result);
  Future<T?> offAll<T>(Widget p, {TransitionType transition = TransitionType.fade}) =>
      _nav.pushAndRemoveUntil<T>(_build<T>(p, transition), (_) => false);
  Future<T?> offUntil<T>(Widget p, RoutePredicate pred, {TransitionType transition = TransitionType.slide}) =>
      _nav.pushAndRemoveUntil<T>(_build<T>(p, transition), pred);
  void back<T>([T? result]) { if (_nav.canPop()) _nav.pop<T>(result); }
  void popUntil(RoutePredicate p) => _nav.popUntil(p);
  bool canPop() => _nav.canPop();
  Future<T?> toNamed<T>(String n, {Object? arguments}) =>
      _nav.pushNamed<T>(n, arguments: arguments);
  Future<T?> replaceNamed<T, R>(String n, {R? result, Object? arguments}) =>
      _nav.pushReplacementNamed<T, R>(n, result: result, arguments: arguments);
  Future<T?> offAllNamed<T>(String n, {Object? arguments}) =>
      _nav.pushNamedAndRemoveUntil<T>(n, (_) => false, arguments: arguments);
}
