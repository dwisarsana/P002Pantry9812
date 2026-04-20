// Garden AI — Splash Screen (Enhanced UI)

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../onboarding/onboarding_screen.dart';
import '../main/home_screen.dart';
import '../../src/constant.dart' show initRevenueCat, isDeveloperModeEnabled;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  String _loadingText = 'Starting Garden AI...';
  int _loadingStep = 0;

  late final AnimationController _logoScale;
  late final AnimationController _fadeIn;
  late final AnimationController _shimmer;
  late final AnimationController _particleCtrl;
  late final AnimationController _progressCtrl;
  late final Animation<double> _logoAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _progressAnimation;

  static const _loadingSteps = [
    'Analyzing landscape layout...',
    'Preparing garden styles...',
    'Loading AI growth models...',
    'Setting up your sanctuary...',
    'Almost ready...',
  ];

  @override
  void initState() {
    super.initState();

    _logoScale = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoScale,
      curve: Curves.elasticOut,
    );

    _fadeIn = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeIn, curve: Curves.easeOut);

    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressCtrl,
      curve: Curves.easeInOut,
    );

    _logoScale.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeIn.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _progressCtrl.forward();
    });

    _cycleLoadingText();
    _navigateAfterSplash();
  }

  void _cycleLoadingText() {
    int i = 0;
    Timer.periodic(const Duration(milliseconds: 520), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _loadingStep = i % _loadingSteps.length;
        _loadingText = _loadingSteps[_loadingStep];
      });
      i++;
    });
  }

  Future<void> _navigateAfterSplash() async {
    await Future.wait([
      _initServices(),
      Future.delayed(const Duration(milliseconds: 2900)),
    ]);
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final bool onboardingDone = prefs.getBool('onboarding_done') ?? false;
    final next = onboardingDone ? const HomeScreen() : const OnboardingScreen();
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(CupertinoPageRoute(builder: (_) => next));
    }
  }

  Future<void> _initServices() async {
    try {
      await initRevenueCat();
    } catch (e) {
      debugPrint('⚠️ RevenueCat init failed: $e');
    }
    await isDeveloperModeEnabled();
  }

  @override
  void dispose() {
    _logoScale.dispose();
    _fadeIn.dispose();
    _shimmer.dispose();
    _particleCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      body: Stack(
        children: [
          // ── Layer 1: Multi-layer ambient glow ──
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _shimmer,
              builder: (_, __) => CustomPaint(
                painter: _MultiGlowPainter(
                  progress: _shimmer.value,
                  color: AppTheme.mossGreen,
                ),
              ),
            ),
          ),

          // ── Layer 2: Floating particles ──
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, __) => CustomPaint(
                painter: _ParticlePainter(
                  progress: _particleCtrl.value,
                  color: AppTheme.mossGreen,
                ),
              ),
            ),
          ),

          // ── Layer 3: Subtle grid lines ──
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(
                color: Colors.white.withValues(alpha: 0.025),
              ),
            ),
          ),

          // ── Layer 4: Main content ──
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo with layered glow rings
                ScaleTransition(
                  scale: _logoAnimation,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow ring
                      AnimatedBuilder(
                        animation: _shimmer,
                        builder: (_, __) => Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.mossGreen.withValues(
                                alpha:
                                    0.06 +
                                    math
                                            .sin(_shimmer.value * math.pi * 2)
                                            .abs() *
                                        0.06,
                              ),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      // Inner glow ring
                      AnimatedBuilder(
                        animation: _shimmer,
                        builder: (_, __) => Container(
                          width: 118,
                          height: 118,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.mossGreen.withValues(
                                alpha:
                                    0.12 +
                                    math
                                            .sin(_shimmer.value * math.pi * 2)
                                            .abs() *
                                        0.08,
                              ),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      // Logo container
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.mossGreen.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 60,
                              spreadRadius: 4,
                            ),
                            BoxShadow(
                              color: AppTheme.mossGreen.withValues(
                                alpha: 0.15,
                              ),
                              blurRadius: 120,
                              spreadRadius: 20,
                            ),
                          ],
                          border: Border.all(
                            color: AppTheme.mossGreen.withValues(
                              alpha: 0.3,
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.asset(
                            'assets/icon.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // App name block
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // "GARDEN" in white, "AI" in accent — editorial split
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'GARDEN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3.0,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.mossGreen,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'AI',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Divider line with accent dot
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppTheme.mossGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 40,
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'INTELLIGENT LANDSCAPE DESIGN',
                        style: TextStyle(
                          color: AppTheme.mossGreen.withValues(
                            alpha: 0.7,
                          ),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 4.0,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 64),

                // Loading section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Segmented progress bar
                      SizedBox(
                        width: 200,
                        child: AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (_, __) {
                            return Row(
                              children: List.generate(5, (i) {
                                final threshold = (i + 1) / 5;
                                final filled =
                                    _progressAnimation.value >= threshold - 0.2;
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: i < 4 ? 4 : 0,
                                    ),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: filled
                                            ? AppTheme.mossGreen
                                            : Colors.white.withValues(
                                                alpha: 0.08,
                                              ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Animated loading text
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: Text(
                          _loadingText,
                          key: ValueKey(_loadingText),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 11.5,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom version tag ──
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const Center(
                child: Text(
                  'Powered by AI',
                  style: TextStyle(
                    color: Colors.white10,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// Custom Painters
// ══════════════════════════════════════════════════════

class _MultiGlowPainter extends CustomPainter {
  final double progress;
  final Color color;
  _MultiGlowPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final pulse = math.sin(progress * math.pi * 2);

    // Primary top-center glow
    _drawGlow(
      canvas,
      center: Offset(size.width / 2, size.height * 0.35),
      radius: size.width * 0.65 + pulse * 18,
      opacity: 0.09 + pulse.abs() * 0.03,
      size: size,
    );

    // Secondary bottom-right accent glow
    _drawGlow(
      canvas,
      center: Offset(size.width * 0.8, size.height * 0.75),
      radius: size.width * 0.35 + pulse * 10,
      opacity: 0.04 + pulse.abs() * 0.02,
      size: size,
    );

    // Tertiary top-left subtle glow
    _drawGlow(
      canvas,
      center: Offset(size.width * 0.15, size.height * 0.2),
      radius: size.width * 0.25,
      opacity: 0.03,
      size: size,
    );
  }

  void _drawGlow(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required double opacity,
    required Size size,
  }) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _MultiGlowPainter old) =>
      old.progress != progress;
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  static const int _count = 20;

  _ParticlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _count; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final phase = rng.nextDouble();
      final radius = 0.8 + rng.nextDouble() * 1.6;

      final t = (progress + phase) % 1.0;
      final y = baseY - t * size.height * 0.12 * speed;
      final opacity = math.sin(t * math.pi) * 0.25;

      if (opacity <= 0) continue;

      paint.color = color.withValues(alpha: opacity);
      canvas.drawCircle(Offset(baseX, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.progress != progress;
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const spacing = 52.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

