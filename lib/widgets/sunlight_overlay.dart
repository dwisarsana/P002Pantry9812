import 'package:flutter/material.dart';

class SunlightOverlay extends StatelessWidget {
  final double opacity;
  const SunlightOverlay({super.key, this.opacity = 0.08});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.5, -0.8),
            radius: 1.5,
            colors: [
              Colors.amber.withValues(alpha: opacity),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
