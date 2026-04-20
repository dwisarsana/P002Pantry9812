import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final double blur;
  final Border? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.opacity = 0.1,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius,
    this.blur = 20,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color.withValues(alpha: opacity),
            borderRadius: borderRadius ?? BorderRadius.circular(24),
            border: border ??
                Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}
