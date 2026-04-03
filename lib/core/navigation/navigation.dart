// lib/core/navigation/navigation.dart
import 'package:flutter/material.dart';
import 'navigation_service.dart';
import 'transition_type.dart';

abstract final class Navigation {
  static final _s = NavigationService.instance;
  static GlobalKey<NavigatorState> get key => _s.navigatorKey;

  static Future<T?> to<T>(Widget p, {TransitionType t = TransitionType.slide}) => _s.push<T>(p, transition: t);
  static Future<T?> replace<T, R>(Widget p, {TransitionType t = TransitionType.slide, R? result}) => _s.replace<T, R>(p, transition: t, result: result);
  static Future<T?> offAll<T>(Widget p, {TransitionType t = TransitionType.fade}) => _s.offAll<T>(p, transition: t);
  static Future<T?> offUntil<T>(Widget p, RoutePredicate pred, {TransitionType t = TransitionType.slide}) => _s.offUntil<T>(p, pred, transition: t);
  static void back<T>([T? result]) => _s.back<T>(result);
  static void popUntil(RoutePredicate p) => _s.popUntil(p);
  static bool canPop() => _s.canPop();
  static Future<T?> toNamed<T>(String n, {Object? args}) => _s.toNamed<T>(n, arguments: args);
  static Future<T?> replaceNamed<T, R>(String n, {R? result, Object? args}) => _s.replaceNamed<T, R>(n, result: result, arguments: args);
  static Future<T?> offAllNamed<T>(String n, {Object? args}) => _s.offAllNamed<T>(n, arguments: args);
}
