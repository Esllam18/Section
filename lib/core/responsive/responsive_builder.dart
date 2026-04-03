// lib/core/responsive/responsive_builder.dart
import 'package:flutter/material.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  const ResponsiveBuilder({super.key, required this.mobile, this.tablet, this.desktop});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, c) {
          if (c.maxWidth >= 1200 && desktop != null) return desktop!;
          if (c.maxWidth >= 600 && tablet != null) return tablet!;
          return mobile;
        },
      );
}
