import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/garden_style.dart';
import 'result_screen.dart';

class RenderingScreen extends StatefulWidget {
  final String originalPath;
  final String resultPath;
  final GardenStyle style;
  final Map<String, dynamic> settings;

  const RenderingScreen({
    super.key,
    required this.originalPath,
    required this.resultPath,
    required this.style,
    required this.settings,
  });

  @override
  State<RenderingScreen> createState() => _RenderingScreenState();
}

class _RenderingScreenState extends State<RenderingScreen> {
  @override
  void initState() {
    super.initState();
    _startRendering();
  }

  void _startRendering() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            originalPath: widget.originalPath,
            resultPath: widget.resultPath,
            style: widget.style,
            settings: widget.settings,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmSand,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Growing Plant Animation
            SizedBox(
              height: 150,
              width: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.wb_sunny_rounded, size: 80, color: AppTheme.sunGlow)
                      .animate(onPlay: (c) => c.repeat())
                      .rotate(duration: 4.seconds),
                  const Icon(Icons.eco_rounded, size: 100, color: AppTheme.mossGreen)
                      .animate()
                      .scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 2.seconds, curve: Curves.elasticOut)
                      .then()
                      .shake(duration: 2.seconds),
                  // Swirling Leaves
                  ...List.generate(5, (index) {
                    return Positioned(
                      child: const Icon(Icons.spa, size: 20, color: Color(0xFF6FAF6F))
                          .animate(onPlay: (c) => c.repeat())
                          .move(
                            begin: const Offset(0, 0),
                            end: Offset(
                              50.0 * (index % 2 == 0 ? 1 : -1),
                              -50.0 - (index * 10),
                            ),
                            duration: 2.seconds,
                          )
                          .fadeIn()
                          .fadeOut(delay: 1500.ms),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              "Cultivating Your Vision...",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.mossGreen,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn().shimmer(duration: 2.seconds),
            const SizedBox(height: 10),
            Text(
              "Applying ${widget.style.name} elements",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
