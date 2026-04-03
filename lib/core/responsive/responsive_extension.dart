// lib/core/responsive/responsive_extension.dart
import 'package:flutter/material.dart';
import 'breakpoints.dart';

extension ResponsiveX on BuildContext {
  double get screenWidth  => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  double w(double f)    => screenWidth  * f.clamp(0.0, 1.0);
  double h(double f)    => screenHeight * f.clamp(0.0, 1.0);
  double r(double size) => size * (screenWidth / Breakpoints.designWidth).clamp(0.75, 1.5);
  double sp(double s)   => s    * (screenWidth / Breakpoints.designWidth).clamp(0.85, 1.3);

  bool get isMobile  => screenWidth < Breakpoints.mobile;
  bool get isTablet  => screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.tablet;
  bool get isDesktop => screenWidth >= Breakpoints.tablet;

  bool get isPortrait  => MediaQuery.orientationOf(this) == Orientation.portrait;
  bool get isLandscape => MediaQuery.orientationOf(this) == Orientation.landscape;

  EdgeInsets get safePadding   => MediaQuery.paddingOf(this);
  double get safeTop           => MediaQuery.paddingOf(this).top;
  double get safeBottom        => MediaQuery.paddingOf(this).bottom;
  double get keyboardHeight    => MediaQuery.viewInsetsOf(this).bottom;
  bool   get isKeyboardVisible => MediaQuery.viewInsetsOf(this).bottom > 0;

  T responsive<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet  && tablet  != null) return tablet;
    return mobile;
  }

  EdgeInsets rAll(double v) => EdgeInsets.all(r(v));
  EdgeInsets rSymmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: r(horizontal), vertical: r(vertical));
  EdgeInsets rOnly({double left=0,double right=0,double top=0,double bottom=0}) =>
      EdgeInsets.only(left:r(left),right:r(right),top:r(top),bottom:r(bottom));
  EdgeInsets get screenPadding => EdgeInsets.symmetric(horizontal: w(0.05));
}
