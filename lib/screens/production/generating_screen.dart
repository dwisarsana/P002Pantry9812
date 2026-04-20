// lib/screens/production/generating_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../models/garden_model.dart';
import '../../models/garden_style.dart';
import '../../services/garden_generation_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import 'result_screen.dart';
import '../../src/constant.dart';

class GeneratingScreen extends StatefulWidget {
  final String imagePath;
  final GardenStyle style;
  final Map<String, dynamic> settings;

  const GeneratingScreen({
    super.key,
    required this.imagePath,
    required this.style,
    required this.settings,
  });

  @override
  State<GeneratingScreen> createState() => _GeneratingScreenState();
}

class _GeneratingScreenState extends State<GeneratingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _rotateCtrl;
  late final AnimationController _pulseCtrl;
  final _service = GardenGenerationService();

  String _statusMessage = 'Analyzing your garden...';
  double _progress = 0.0;
  bool _hasError = false;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _generate();
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _pulseCtrl.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final messages = [
      (0.1, 'Analyzing garden space...'),
      (0.25, 'Building style prompt...'),
      (0.45, 'Connecting to AI service...'),
      (0.65, 'Generating your garden design...'),
      (0.85, 'Finalizing details...'),
    ];

    // Simulate progress while waiting for API
    for (final (p, msg) in messages) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() {
        _progress = p;
        _statusMessage = msg;
      });
    }

    try {
      // Re-check gate on retry just in case
      final canProceed = await PremiumGate.checkGate(context);
      if (!canProceed) {
        if (mounted) Navigator.pop(context);
        return;
      }

      final resultUrl = await _service.generate(
        imagePath: widget.imagePath,
        styleName: widget.style.name,
        settings: widget.settings,
      );

      if (!mounted) return;

      if (resultUrl == null) {
        setState(() {
          _hasError = true;
          _errorMsg = 'Generation failed. Please try again.';
        });
        return;
      }

      // ── CONSUME TOKEN OR QUOTA HERE ──
      await PremiumGate.consumeQuotaOrToken();

      setState(() {
        _progress = 1.0;
        _statusMessage = 'Your garden is ready!';
      });

      // Save to history
      await _saveToHistory(resultUrl);

      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            originalPath: widget.imagePath,
            resultPath: resultUrl,
            style: widget.style,
            settings: widget.settings,
          ),
        ),
      );
    } on UnsafePromptException catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMsg = e.message;
      });
    } on NetworkException catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMsg = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMsg = 'An unexpected error occurred.';
      });
    }
  }

  Future<void> _saveToHistory(String resultUrl) async {
    try {
      final storage = context.read<StorageService>();
      final current = await storage.loadGardens();
      final garden = GardenModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        originalImagePath: widget.imagePath,
        resultImagePath: resultUrl,
        styleName: widget.style.name,
        timestamp: DateTime.now(),
        settings: widget.settings,
      );
      await storage.saveGardens([garden, ...current]);
      // Increment session count for settings screen
      await incrementTotalGenerationCount();
    } catch (e) {
      debugPrint('[GeneratingScreen] Failed to save to history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_hasError) _buildError() else _buildProgress(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated garden icon
        SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _rotateCtrl,
                builder: (_, child) => Transform.rotate(
                  angle: _rotateCtrl.value * 6.28,
                  child: child,
                ),
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.mossGreen.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    gradient: SweepGradient(
                      colors: [
                        AppTheme.mossGreen.withValues(alpha: 0.0),
                        AppTheme.mossGreen.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, child) => Transform.scale(
                  scale: 0.9 + (_pulseCtrl.value * 0.1),
                  child: child,
                ),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.mossGreen.withValues(alpha: 0.15),
                  ),
                  child: Image.asset(
                    'assets/icon.png',
                    width: 70,
                    height: 70,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Style name badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.mossGreen.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.mossGreen.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: AppTheme.mintGreen, size: 16),
              const SizedBox(width: 8),
              Text(
                widget.style.name,
                style: const TextStyle(
                  color: AppTheme.mintGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Creating Your Garden',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(),

        const SizedBox(height: 8),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Text(
            _statusMessage,
            key: ValueKey(_statusMessage),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 40),

        // Progress bar
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: AppTheme.mintGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: _progress),
                duration: const Duration(milliseconds: 600),
                builder: (_, val, __) => LinearProgressIndicator(
                  value: val,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppTheme.mossGreen),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        // Preview of original image
        if (File(widget.imagePath).existsSync())
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(
              File(widget.imagePath),
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ).animate().fadeIn(delay: 500.ms).blur(
                begin: const Offset(10, 10),
                end: Offset.zero,
                duration: 800.ms,
              ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.redAccent.withValues(alpha: 0.15),
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            size: 52,
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Generation Failed',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          _errorMsg,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _progress = 0.0;
                    _statusMessage = 'Retrying...';
                  });
                  _generate();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.mossGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
