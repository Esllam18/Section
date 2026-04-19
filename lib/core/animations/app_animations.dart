import 'package:flutter/material.dart';

abstract final class AppAnimations {
  static Curve _dc(Duration d, Duration dur, Curve c) {
    if (d == Duration.zero) return c;
    final t = d.inMilliseconds + dur.inMilliseconds;
    return Interval(d.inMilliseconds / t, 1.0, curve: c);
  }

  static Duration _td(Duration d, Duration dur) => d == Duration.zero
      ? dur
      : Duration(milliseconds: d.inMilliseconds + dur.inMilliseconds);

  static Widget fade(
          {required Widget child,
          required Duration duration,
          Curve curve = Curves.easeOut,
          Duration delay = Duration.zero,
          double begin = 0.0}) =>
      TweenAnimationBuilder<double>(
          tween: Tween(begin: begin, end: 1.0),
          duration: _td(delay, duration),
          curve: _dc(delay, duration, curve),
          child: child,
          builder: (_, v, c) => Opacity(opacity: v.clamp(0.0, 1.0), child: c));

  static Widget scale(
          {required Widget child,
          required Duration duration,
          Curve curve = Curves.easeOutBack,
          Duration delay = Duration.zero,
          double beginScale = 0.0,
          Alignment alignment = Alignment.center}) =>
      TweenAnimationBuilder<double>(
          tween: Tween(begin: beginScale, end: 1.0),
          duration: _td(delay, duration),
          curve: _dc(delay, duration, curve),
          child: child,
          builder: (_, v, c) => Transform.scale(
              scale: v.clamp(0.0, 1.15), alignment: alignment, child: c));

  static Widget slide(
          {required Widget child,
          required Duration duration,
          Curve curve = Curves.easeOutCubic,
          Duration delay = Duration.zero,
          SlideDir dir = SlideDir.up,
          double dist = 32.0}) =>
      TweenAnimationBuilder<Offset>(
          tween: Tween(begin: _off(dir, dist), end: Offset.zero),
          duration: _td(delay, duration),
          curve: _dc(delay, duration, curve),
          child: child,
          builder: (_, v, c) => Transform.translate(offset: v, child: c));

  static Offset _off(SlideDir d, double dist) => switch (d) {
        SlideDir.up => Offset(0, dist),
        SlideDir.down => Offset(0, -dist),
        SlideDir.left => Offset(-dist, 0),
        SlideDir.right => Offset(dist, 0),
      };

  static Widget fadeSlide(
          {required Widget child,
          required Duration duration,
          Curve curve = Curves.easeOutCubic,
          Duration delay = Duration.zero,
          SlideDir dir = SlideDir.up,
          double dist = 32.0}) =>
      fade(
          duration: duration,
          delay: delay,
          curve: curve,
          child: slide(
              duration: duration,
              delay: delay,
              curve: curve,
              dir: dir,
              dist: dist,
              child: child));

  static Widget fadeScale(
          {required Widget child,
          required Duration duration,
          Curve curve = Curves.easeOutBack,
          Duration delay = Duration.zero,
          double beginScale = 0.6}) =>
      fade(
          duration: duration,
          delay: delay,
          child: scale(
              duration: duration,
              delay: delay,
              curve: curve,
              beginScale: beginScale,
              child: child));
}

enum SlideDir { up, down, left, right }
