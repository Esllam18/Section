// lib/core/responsive/responsive_extension.dart
import 'package:flutter/material.dart';
import 'breakpoints.dart';

extension ResponsiveX on BuildContext {
  double get sw => MediaQuery.sizeOf(this).width;
  double get sh => MediaQuery.sizeOf(this).height;
  double w(double f)    => sw * f.clamp(0.0, 1.0);
  double h(double f)    => sh * f.clamp(0.0, 1.0);
  double r(double size) => size * (sw / Breakpoints.designWidth).clamp(0.75, 1.5);
  double sp(double s)   => s * (sw / Breakpoints.designWidth).clamp(0.85, 1.3);
  bool get isMobile     => sw < Breakpoints.mobile;
  bool get isTablet     => sw >= Breakpoints.mobile;
  bool get isRTL        => Directionality.of(this) == TextDirection.rtl;
  double get safeTop    => MediaQuery.paddingOf(this).top;
  double get safeBottom => MediaQuery.paddingOf(this).bottom;
  EdgeInsets rAll(double v) => EdgeInsets.all(r(v));
  EdgeInsets rSym({double h = 0, double v = 0}) =>
      EdgeInsets.symmetric(horizontal: r(h), vertical: r(v));
  EdgeInsets rOnly({double l = 0, double ri = 0, double t = 0, double b = 0}) =>
      EdgeInsets.only(left: r(l), right: r(ri), top: r(t), bottom: r(b));
  EdgeInsets get hPad => rSym(h: 20);
}
