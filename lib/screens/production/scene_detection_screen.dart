// lib/screens/create/scene_detection_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import 'style_library_screen.dart';

class SceneDetectionScreen extends StatefulWidget {
  final String imagePath;
  const SceneDetectionScreen({super.key, required this.imagePath});

  @override
  State<SceneDetectionScreen> createState() => _SceneDetectionScreenState();
}

class _SceneDetectionScreenState extends State<SceneDetectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  int _currentStep = 0;
  bool _scanComplete = false;

  final List<Map<String, dynamic>> _analysisSteps = [
    {'label': 'Detecting boundaries...', 'icon': Icons.crop_rounded},
    {'label': 'Analyzing vegetation...', 'icon': Icons.grass_rounded},
    {'label': 'Measuring light conditions...', 'icon': Icons.wb_sunny_rounded},
    {'label': 'Identifying structures...', 'icon': Icons.home_rounded},
    {'label': 'Mapping terrain...', 'icon': Icons.terrain_rounded},
  ];

  final List<Map<String, dynamic>> _detectedTags = [
    {
      'label': 'Open Backyard',
      'confidence': 0.95,
      'icon': Icons.zoom_out_map,
      'position': const Offset(0.2, 0.3),
    },
    {
      'label': 'Sparse Vegetation',
      'confidence': 0.88,
      'icon': Icons.grass,
      'position': const Offset(0.6, 0.5),
    },
    {
      'label': 'Sunny Exposure',
      'confidence': 0.92,
      'icon': Icons.wb_sunny_rounded,
      'position': const Offset(0.15, 0.15),
    },
    {
      'label': 'Modern Fence',
      'confidence': 0.85,
      'icon': Icons.fence,
      'position': const Offset(0.75, 0.25),
    },
    {
      'label': 'Flat Terrain',
      'confidence': 0.91,
      'icon': Icons.terrain,
      'position': const Offset(0.5, 0.7),
    },
    {
      'label': 'Patio Area',
      'confidence': 0.78,
      'icon': Icons.deck,
      'position': const Offset(0.3, 0.65),
    },
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _startAnalysis();
  }

  void _startAnalysis() async {
    for (int i = 0; i < _analysisSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (mounted) setState(() => _currentStep = i + 1);
    }
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _scanComplete = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, animation, _) =>
                StyleLibraryScreen(imagePath: widget.imagePath),
            transitionsBuilder: (_, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Widget _buildImageWidget() {
    if (widget.imagePath.startsWith('http')) {
      return Image.network(widget.imagePath, fit: BoxFit.cover);
    }
    return Image.file(File(widget.imagePath), fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(child: _buildImageWidget()),

          // Dark overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.7),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                  stops: const [0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // Scanning line
          if (!_scanComplete)
            AnimatedBuilder(
              animation: _scanController,
              builder: (context, child) {
                return Positioned(
                  top: size.height * _scanController.value,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppTheme.mossGreen.withValues(alpha: 0.8),
                          AppTheme.mintGreen,
                          AppTheme.mossGreen.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.mossGreen.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // Corner brackets (scanning frame)
          if (!_scanComplete) ...[
            _CornerBracket(
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.only(top: 100, left: 30),
            ),
            _CornerBracket(
              alignment: Alignment.topRight,
              margin: const EdgeInsets.only(top: 100, right: 30),
              rotation: 1,
            ),
            _CornerBracket(
              alignment: Alignment.bottomLeft,
              margin: const EdgeInsets.only(bottom: 250, left: 30),
              rotation: 3,
            ),
            _CornerBracket(
              alignment: Alignment.bottomRight,
              margin: const EdgeInsets.only(bottom: 250, right: 30),
              rotation: 2,
            ),
          ],

          // Detection Tags
          ...List.generate(_detectedTags.length, (index) {
            final tag = _detectedTags[index];
            final pos = tag['position'] as Offset;
            final shouldShow =
                _currentStep > (index * _analysisSteps.length / _detectedTags.length).floor();

            if (!shouldShow) return const SizedBox.shrink();

            return Positioned(
              left: size.width * pos.dx,
              top: size.height * pos.dy,
              child: _DetectionTag(
                label: tag['label'] as String,
                confidence: tag['confidence'] as double,
                icon: tag['icon'] as IconData,
                delay: Duration(milliseconds: index * 300),
              ),
            );
          }),

          // Bottom Analysis Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 50),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.95),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status header
                  Row(
                    children: [
                      if (!_scanComplete)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation(
                                AppTheme.mossGreen),
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                          ),
                        )
                      else
                        const Icon(Icons.check_circle_rounded,
                            color: AppTheme.mossGreen, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        _scanComplete
                            ? 'Analysis Complete!'
                            : 'Analyzing Your Space...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Progress steps
                  ...List.generate(_analysisSteps.length, (index) {
                    final step = _analysisSteps[index];
                    final isDone = _currentStep > index;
                    final isCurrent = _currentStep == index;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isDone
                                  ? AppTheme.mossGreen.withValues(alpha: 0.2)
                                  : isCurrent
                                      ? AppTheme.sunGlow.withValues(alpha: 0.2)
                                      : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isDone
                                  ? Icons.check_rounded
                                  : step['icon'] as IconData,
                              color: isDone
                                  ? AppTheme.mossGreen
                                  : isCurrent
                                      ? AppTheme.sunGlow
                                      : Colors.white30,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step['label'] as String,
                              style: TextStyle(
                                color: isDone
                                    ? Colors.white70
                                    : isCurrent
                                        ? Colors.white
                                        : Colors.white24,
                                fontSize: 13,
                                fontWeight: isCurrent
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (isDone)
                            Text(
                              '✓',
                              style: TextStyle(
                                color: AppTheme.mossGreen,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ).animate().fadeIn(
                        delay: Duration(milliseconds: index * 200));
                  }),

                  const SizedBox(height: 16),

                  // Overall progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      height: 4,
                      child: LinearProgressIndicator(
                        value: _currentStep / _analysisSteps.length,
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation(
                          _scanComplete
                              ? AppTheme.mossGreen
                              : AppTheme.sunGlow,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top status bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _scanComplete ? AppTheme.mossGreen : Colors.red,
                          boxShadow: [
                            BoxShadow(
                              color: (_scanComplete
                                      ? AppTheme.mossGreen
                                      : Colors.red)
                                  .withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _scanComplete ? 'DONE' : 'SCANNING',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(_currentStep / _analysisSteps.length * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn().slideY(begin: -0.5),
          ),
        ],
      ),
    );
  }
}

class _CornerBracket extends StatelessWidget {
  final Alignment alignment;
  final EdgeInsets margin;
  final int rotation;

  const _CornerBracket({
    required this.alignment,
    required this.margin,
    this.rotation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: margin,
          child: RotatedBox(
            quarterTurns: rotation,
            child: CustomPaint(
              size: const Size(30, 30),
              painter: _BracketPainter(),
            ),
          ),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn()
        .then()
        .fade(begin: 1, end: 0.4, duration: 1500.ms);
  }
}

class _BracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.mossGreen
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DetectionTag extends StatelessWidget {
  final String label;
  final double confidence;
  final IconData icon;
  final Duration delay;

  const _DetectionTag({
    required this.label,
    required this.confidence,
    required this.icon,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.mossGreen.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.mossGreen.withValues(alpha: 0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.mossGreen),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.mossGreen.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${(confidence * 100).toInt()}%',
              style: const TextStyle(
                color: AppTheme.mintGreen,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay).scale(
          begin: const Offset(0.8, 0.8),
          curve: Curves.easeOutBack,
        );
  }
}