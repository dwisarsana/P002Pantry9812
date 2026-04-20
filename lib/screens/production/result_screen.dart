// lib/screens/production/result_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../models/garden_style.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../main/main_screen.dart';
import '../account/history_screen.dart';

class ResultScreen extends StatefulWidget {
  final String originalPath;
  final String resultPath;
  final GardenStyle style;
  final Map<String, dynamic> settings;

  const ResultScreen({
    super.key,
    required this.originalPath,
    required this.resultPath,
    required this.style,
    required this.settings,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  double _sliderX = 0.5;
  bool _showSlider = true;
  bool _isSaved = true; // Auto-saved by GeneratingScreen
  bool _isFavorite = false;

  Widget _buildImg(String path, {BoxFit fit = BoxFit.cover}) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: fit,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.mintGreen),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => const _ImageError(),
      );
    }
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(file, fit: fit, errorBuilder: (_, __, ___) => const _ImageError());
    }
    return const _ImageError();
  }

  void _saveGarden() async {
    HapticFeedback.mediumImpact();
    final storage = context.read<StorageService>();
    final current = await storage.loadGardens();

    // Avoid duplicate saves (already saved by GeneratingScreen)
    final alreadySaved = current.any((g) =>
        g.resultImagePath == widget.resultPath &&
        g.originalImagePath == widget.originalPath);

    if (!alreadySaved) {
      await storage.saveGardens(current); // already saved by generating screen
    }

    if (mounted) {
      setState(() => _isSaved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: AppTheme.mossGreen,
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Saved to your garden collection!',
                  style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Before/After Comparison Slider ────────────────────────────
          Positioned.fill(
            child: GestureDetector(
              onPanUpdate: (d) {
                setState(() {
                  _sliderX += d.delta.dx / MediaQuery.of(context).size.width;
                  _sliderX = _sliderX.clamp(0.02, 0.98);
                });
              },
              onTap: () => setState(() => _showSlider = !_showSlider),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Before (original) — full frame
                  _buildImg(widget.originalPath),

                  // After (result) — clipped to right of slider
                  ClipRect(
                    clipper: _RightClipper(_sliderX),
                    child: _buildImg(widget.resultPath),
                  ),

                  // Divider line + handle
                  if (_showSlider)
                    Positioned(
                      left: MediaQuery.of(context).size.width * _sliderX - 20,
                      top: 0,
                      bottom: 0,
                      child: SizedBox(
                        width: 40,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // White line
                            Container(
                              width: 2,
                              height: double.infinity,
                              color: Colors.white,
                            ),
                            // Handle
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chevron_left,
                                      size: 18, color: AppTheme.charcoal),
                                  Icon(Icons.chevron_right,
                                      size: 18, color: AppTheme.charcoal),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Before / After labels ──────────────────────────────────────
          if (_showSlider)
            Positioned(
              top: 80,
              left: 16,
              child: _Label(text: 'BEFORE', color: Colors.white70),
            ),
          if (_showSlider)
            Positioned(
              top: 80,
              right: 16,
              child: _Label(
                  text: 'AFTER', color: AppTheme.sunGlow),
            ),

          // ── Top bar ───────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: _goHome,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.home_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.history_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 16),
                Image.asset('assets/icon.png', width: 32, height: 32),
                const SizedBox(width: 8),
                const Text(
                  'Garden AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    setState(() => _isFavorite = !_isFavorite);
                    HapticFeedback.lightImpact();
                    // Perspective: We need the ID to update storage.
                    // For now, we'll try to find it by path.
                    final storage = context.read<StorageService>();
                    final gardens = await storage.loadGardens();
                    final index = gardens.indexWhere((g) => g.resultImagePath == widget.resultPath);
                    if (index != -1) {
                      await storage.toggleFavorite(gardens[index].id);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        key: ValueKey(_isFavorite),
                        color:
                            _isFavorite ? Colors.redAccent : Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn().slideY(begin: -0.3),
          ),

          // ── Bottom panel ──────────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                  stops: const [0, 0.3, 1],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 50, 24, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Slider hint
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.compare_rounded,
                                color: Colors.white60, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Drag slider to compare',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Success badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.mossGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.mossGreen.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_rounded,
                            color: AppTheme.mintGreen, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Transformation Complete',
                          style: TextStyle(
                            color: AppTheme.mintGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    widget.style.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    widget.style.moodDescription.isNotEmpty
                        ? widget.style.moodDescription
                        : widget.style.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isSaved ? null : _saveGarden,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isSaved
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : AppTheme.mossGreen,
                              disabledBackgroundColor:
                                  Colors.white.withValues(alpha: 0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: _isSaved ? 0 : 6,
                              shadowColor:
                                  AppTheme.mossGreen.withValues(alpha: 0.4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isSaved
                                      ? Icons.check_circle_rounded
                                      : Icons.save_alt_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isSaved ? 'Saved!' : 'Save to Gallery',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _ActionBtn(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        onTap: _goHome,
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
          ),
        ],
      ),
    );
  }
}

// ── Supporting widgets ──────────────────────────────────────────────────────

class _RightClipper extends CustomClipper<Rect> {
  final double split;
  _RightClipper(this.split);

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(size.width * split, 0, size.width * (1 - split), size.height);

  @override
  bool shouldReclip(_RightClipper old) => old.split != split;
}

class _Label extends StatelessWidget {
  final String text;
  final Color color;
  const _Label({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageError extends StatelessWidget {
  const _ImageError();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.charcoal,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_rounded, color: Colors.white30, size: 48),
            SizedBox(height: 8),
            Text('Image unavailable',
                style: TextStyle(color: Colors.white30, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}