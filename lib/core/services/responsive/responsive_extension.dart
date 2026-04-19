import 'package:flutter/material.dart';
extension ResponsiveExtension on BuildContext {
  double get screenWidth  => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isMobile  => screenWidth < 768;
  bool get isTablet  => screenWidth >= 768 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;
  double get hPad => isMobile ? 16.0 : isTablet ? 32.0 : 64.0;
}
