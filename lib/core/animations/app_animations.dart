// lib/core/animations/app_animations.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

abstract final class AppAnimations {
  static Curve _delayCurve(Duration delay, Duration dur, Curve c) {
    if (delay == Duration.zero) return c;
    final total = delay.inMilliseconds + dur.inMilliseconds;
    return Interval(delay.inMilliseconds / total, 1.0, curve: c);
  }

  static Duration _total(Duration delay, Duration dur) => delay == Duration.zero
      ? dur
      : Duration(milliseconds: delay.inMilliseconds + dur.inMilliseconds);

  static Widget fade({
    required Widget child,
    required Duration duration,
    Curve curve = Curves.easeOut,
    Duration delay = Duration.zero,
    double beginOpacity = 0.0,
  }) =>
      TweenAnimationBuilder<double>(
        tween: Tween(begin: beginOpacity, end: 1.0),
        duration: _total(delay, duration),
        curve: _delayCurve(delay, duration, curve),
        child: child,
        builder: (_, v, c) => Opacity(opacity: v.clamp(0.0, 1.0), child: c),
      );

  static Widget scale({
    required Widget child,
    required Duration duration,
    Curve curve = Curves.elasticOut,
    Duration delay = Duration.zero,
    double beginScale = 0.0,
    Alignment alignment = Alignment.center,
  }) =>
      TweenAnimationBuilder<double>(
        tween: Tween(begin: beginScale, end: 1.0),
        duration: _total(delay, duration),
        curve: _delayCurve(delay, duration, curve),
        child: child,
        builder: (_, v, c) =>
            Transform.scale(scale: v.clamp(0.0, 1.2), alignment: alignment, child: c),
      );

  static Widget slide({
    required Widget child,
    required Duration duration,
    Curve curve = Curves.easeOutCubic,
    Duration delay = Duration.zero,
    SlideDirection direction = SlideDirection.up,
    double distance = 40.0,
  }) =>
      TweenAnimationBuilder<Offset>(
        tween: Tween(begin: _off(direction, distance), end: Offset.zero),
        duration: _total(delay, duration),
        curve: _delayCurve(delay, duration, curve),
        child: child,
        builder: (_, v, c) => Transform.translate(offset: v, child: c),
      );

  static Offset _off(SlideDirection d, double dist) => switch (d) {
        SlideDirection.up    => Offset(0, dist),
        SlideDirection.down  => Offset(0, -dist),
        SlideDirection.left  => Offset(-dist, 0),
        SlideDirection.right => Offset(dist, 0),
      };

  static Widget rotation({
    required Widget child,
    required Duration duration,
    Curve curve = Curves.easeOut,
    Duration delay = Duration.zero,
    double beginDegrees = -180.0,
    double endDegrees = 0.0,
    Alignment alignment = Alignment.center,
  }) =>
      TweenAnimationBuilder<double>(
        tween: Tween(begin: beginDegrees, end: endDegrees),
        duration: _total(delay, duration),
        curve: _delayCurve(delay, duration, curve),
        child: child,
        builder: (_, v, c) =>
            Transform.rotate(angle: v * math.pi / 180, alignment: alignment, child: c),
      );

  static Widget size({
    required Widget child,
    required Duration duration,
    Curve curve = Curves.easeOut,
    Duration delay = Duration.zero,
    Axis axis = Axis.vertical,
    double beginSize = 0.0,
  }) =>
      TweenAnimationBuilder<double>(
        tween: Tween(begin: beginSize, end: 1.0),
        duration: _total(delay, duration),
        curve: _delayCurve(delay, duration, curve),
        child: child,
        builder: (_, v, c) => ClipRect(
          child: Align(
            alignment: Alignment.center,
            heightFactor: axis == Axis.vertical ? v.clamp(0.0, 1.0) : 1.0,
            widthFactor:  axis == Axis.horizontal ? v.clamp(0.0, 1.0) : 1.0,
            child: c,
          ),
        ),
      );

  static Widget combined({
    required Widget child,
    required Duration duration,
    CombineType type = CombineType.fadeSlide,
    Curve curve = Curves.easeOut,
    Duration delay = Duration.zero,
    SlideDirection direction = SlideDirection.up,
    double slideDistance = 40.0,
    double beginScale = 0.0,
  }) =>
      switch (type) {
        CombineType.fadeSlide => fade(
            duration: duration, delay: delay, curve: curve,
            child: slide(duration: duration, delay: delay, curve: curve,
                direction: direction, distance: slideDistance, child: child)),
        CombineType.fadeScale => fade(
            duration: duration, delay: delay, curve: curve,
            child: scale(duration: duration, delay: delay, curve: curve,
                beginScale: beginScale, child: child)),
        CombineType.scaleSlide => scale(
            duration: duration, delay: delay, curve: curve, beginScale: beginScale,
            child: slide(duration: duration, delay: delay, curve: curve,
                direction: direction, distance: slideDistance, child: child)),
      };
}

enum SlideDirection { up, down, left, right }
enum CombineType { fadeSlide, fadeScale, scaleSlide }
